# frozen_string_literal: true

module ApplicationHelper
  include StyleHelper

  def modal_dom_id(resource)
    "#{resource.model_name.singular}-modal_#{resource.id}"
  end

  def omniauth_authorize_path(_resource_name, _provider)
    user_google_omniauth_authorize_path
  end

  def page_title
    Rails.application.class.module_parent_name
  end
end
