# frozen_string_literal: true

require 'rails_helper'

module PayPal
  # Faraday RSpec example: https://github.com/lostisland/faraday/blob/main/examples/client_spec.rb
  RSpec.describe SyncProductsJob, type: :job do
    around do |example|
      Sidekiq::Testing.inline! { example.run }
    end

    context 'when the request is authorized' do
      around do |example|
        VCR.use_cassette(
          'paypal/sync_products',
          # NOTE: in development, change to `record: :new_episodes` to update the cassette
          record: :none
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

      it 'syncs products' do
        # TODO: Make this less brittle - assert on specific records that are in the
        #   PayPal sandbox account (and/or VCR cassette)
        expect { described_class.perform_now }.to change { Product.count }.by(7).and \
          change { Metadata::Product.count }.by(7)
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
        stubs.get(%r{/v1/catalogs/products}) do
          raise Faraday::UnauthorizedError, 'Unauthorized'
        end

        described_class.perform_now
        expect(Rails.logger).to have_received(:error).with(/failed/, { message: 'Unauthorized' })
      end
    end
  end
end
