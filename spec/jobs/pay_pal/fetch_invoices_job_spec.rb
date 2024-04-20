# frozen_string_literal: true

require 'rails_helper'

module PayPal
  RSpec.describe FetchInvoicesJob, type: :job do
    around do |example|
      Sidekiq::Testing.inline! { example.run }
    end

    context 'when the request is authorized' do
      # around do |example|
      #   VCR.use_cassette(
      #     'paypal/fetch_invoices',
      #     record: :new_episodes,
      #     re_record_interval: 3.months
      #   ) do
      #     example.run
      #   end
      # end

      it 'fetches invoices' do
        expect { described_class.perform_now }.to change { Invoice.count }.by(5)
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
        expect(Rails.logger).to have_received(:error).with(/failed: Unauthorized/)
      end
    end
  end
end