# frozen_string_literal: true

require 'rails_helper'

module PayPal
  RSpec.describe FetchInvoicesJob, type: :job do
    around do |example|
      Sidekiq::Testing.inline! { example.run }
    end

    context 'when the request is authorized' do
      around do |example|
        # API docs: https://rubydoc.info/gems/vcr/6.2.0/VCR#use_cassette-instance_method
        VCR.use_cassette(
          'paypal/fetch_invoices',
          # NOTE: in development, change to `record: :new_episodes` to update the cassette
          record: :none,
          tag: :obfuscate
        ) do
          # NOTE: When working in development to update the cassette, disable this block
          with_modified_env(
            PAYPAL_API_BASE_URL: Rails.application.credentials.paypal.api_base_url,
            PAYPAL_CLIENT_ID: Rails.application.credentials.paypal.client_id,
            PAYPAL_CLIENT_SECRET: Rails.application.credentials.paypal.client_secret
          ) do
            example.run
          end
          # NOTE: When working in development to update the cassette, enable this line
          #   after disabling ☝🏾 block
          # example.run
        end
      end

      it 'fetches invoices' do
        expect { described_class.perform_now }.to change { Invoice.count }.by(48)
      end
    end

    context 'when the request is unauthorized' do
      let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
      let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }

      before do
        allow_any_instance_of(described_class).to receive(:connection) { conn }
        allow(Rails.logger).to receive(:error)
      end

      after do
        allow_any_instance_of(described_class).to receive(:connection).and_call_original
      end

      it 'the expected exception is handled' do
        stubs.get(%r{/v2/invoicing/invoices}) do
          raise Faraday::UnauthorizedError, 'Unauthorized'
        end

        described_class.perform_now
        expect(Rails.logger).to have_received(:error).with(/failed/, { message: 'Unauthorized' })
      end
    end
  end
end
