# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/services', type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Service. As you add validations to Service, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Service.create! valid_attributes
      get services_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      service = Service.create! valid_attributes
      get service_url(service)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    let(:user) { Fabricate :user }

    before do
      sign_in user
    end

    it 'renders a successful response' do
      get new_service_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      service = Service.create! valid_attributes
      get edit_service_url(service)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Service' do
        expect do
          post services_url, params: { service: valid_attributes }
        end.to change(Service, :count).by(1)
      end

      it 'redirects to the created service' do
        post services_url, params: { service: valid_attributes }
        expect(response).to redirect_to(service_url(Service.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Service' do
        expect do
          post services_url, params: { service: invalid_attributes }
        end.to change(Service, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post services_url, params: { service: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested service' do
        service = Service.create! valid_attributes
        patch service_url(service), params: { service: new_attributes }
        service.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the service' do
        service = Service.create! valid_attributes
        patch service_url(service), params: { service: new_attributes }
        service.reload
        expect(response).to redirect_to(service_url(service))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        service = Service.create! valid_attributes
        patch service_url(service), params: { service: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested service' do
      service = Service.create! valid_attributes
      expect do
        delete service_url(service)
      end.to change(Service, :count).by(-1)
    end

    it 'redirects to the services list' do
      service = Service.create! valid_attributes
      delete service_url(service)
      expect(response).to redirect_to(services_url)
    end
  end
end
