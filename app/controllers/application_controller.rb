# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :name, :email, :password)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:first_name, :last_name, :name, :email, :password, :password_confirmation, :current_password)
    end
  end
end
