# frozen_string_literal: true

module PayPal
  # TODO: Works in tandem with invoice update webhooks to fetch invoices
  #   and keep invoicing data in sync with PayPal
  class FetchInvoicesJob < AbstractJob
    attr_accessor :skipped_records, :enqueued_records, :error_records

    PAGE_LIMIT = 10

    def perform(*_args)
      @enqueued_records = []
      @processed_records = []
      # TODO: Implement a way to perform cherry-picked upserts for records that already exist
      @skipped_records = []
      @error_records = []
      # TODO: Calculate the page number to start fetching from based on
      #   the number of invoice records in the database
      page = 1
      start_page = page
      next_link = fetch(page:)
      while next_link && page < (start_page + PAGE_LIMIT)
        page += 1
        next_link = fetch(page:)
      end

      Rails.logger.info "Found #{enqueued_records.count} records to process"

      @enqueued_records.each do |record|
        if Invoice.exists?(vendor_record_id: record['id'])
          @skipped_records << record
          Rails.logger.info("Skipping record with ID #{record['id']} because it already exists", record:)
          next
        end

        @processed_records << process_record(record)
      rescue StandardError => e
        Rails.logger.error "#{self.class.name} invoice record(s) failed to process",
                           record:, message: e.message
        @error_records << record
      end

      Rails.logger.info "#{skipped_records.count} invoice records were skipped" if skipped_records.any?

      if @error_records.any?
        Rails.logger.error "#{error_records.count} invoice records that failed to process"
      else
        # TODO: Generate batch ID from starting page range and timestamp
        Rails.logger.info 'All enqueued invoice records were processed successfully'
      end

      # Batch create the records
      results = Invoice.create(@processed_records)

      if results&.all?(&:valid?)
        Rails.logger.info "Saved #{results.count} records"
      else
        saved_records = results.reject { |record| record.errors.any? }
        Rails.logger.warn "Saved #{saved_records.count} of #{@processed_records.count} records"
        # IMPORTANT: Error records will now have contents that are either
        #   hashes or invalid instances of Invoice
        @error_records += results.select { |record| record.errors.any? }
        Rails.logger.error "Failed to save #{error_records.count} records"
      end
    rescue StandardError => e
      Rails.logger.error "#{self.class.name} failed", message: e.message
    end

    def fetch(page: 1)
      response = connection.get('/v2/invoicing/invoices') do |req|
        req.options.params_encoder = Faraday::FlatParamsEncoder
        req.params = { page_size: 25, page: }
      end
      data = response.body
      # Links are for pagination
      links, items = data.values_at('links', 'items')
      @enqueued_records += items
      return nil unless links.is_a?(Array)

      # Return next page link
      links.find { |link| link['rel'] == 'next' }
    end

    def process_record(record)
      vendor_record_id = record['id']
      status, detail, invoicer, primary_recipients,
        amount, due_amount, payments, links, vendor_recurring_group_id = record.values_at(
          'status', 'detail', 'invoicer', 'primary_recipients',
          'amount', 'due_amount', 'payments', 'links', 'recurring_Id'
        )
      invoice_number, invoiced_at, viewed_by_recipient,
        currency_code, note = detail.values_at(
          'invoice_number', 'invoice_date', 'viewed_by_recipient',
          'currency_code', 'note'
        )
      due_at = detail.dig('payment_term', 'due_date')
      accounts = []
      # Extract individual accounts
      (primary_recipients || []).each do |recipient|
        given_name = recipient.dig('billing_info', 'name', 'given_name')
        family_name = recipient.dig('billing_info', 'name', 'surname')
        display_name = recipient.dig('billing_info', 'name', 'full_name')
        email = recipient.dig('billing_info', 'email_address')
        accounts << {
          given_name:, family_name:, display_name:,
          email:, type: 'Individual'
        }
        business_name = recipient.dig('billing_info', 'business_name')
        next unless business_name.present?

        accounts << { display_name: business_name, type: 'Business' }
      end

      {
        vendor_record_id:,
        vendor_recurring_group_id:,
        invoice_number:,
        vendor_id: vendor.id,
        payment_vendor: 'paypal',
        status:,
        invoicer:,
        accounts:,
        viewed_by_recipient:,
        invoiced_at:,
        due_at:,
        currency_code:,
        amount:,
        due_amount:,
        payments:,
        note:,
        links:
      }
    end
  end
end
