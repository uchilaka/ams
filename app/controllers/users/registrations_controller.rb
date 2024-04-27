# frozen_string_literal: true

module Users
  # Kind of ancient, but hopefully still useful: https://gist.github.com/kinopyo/2343176
  class RegistrationsController < Devise::RegistrationsController
    before_action :assign_default_role, only: %i[edit update]
    before_action :calculate_global_privilege_level,
                  :set_available_roles, only: %i[edit update]
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    attr_accessor :global_privilege_level, :most_privileged_role, :available_roles

    # # GET /resource/sign_up
    # def new
    #   super
    # end
    #
    # # POST /resource
    # def create
    #   super
    # end
    #
    # GET /resource/edit
    def edit
      super
      # Check for highest privilege role that the user has
      _most_privileged_role, role_params = ordered_role_entries.find { |(role, _role_tuple)| resource.has_role?(role) }
      privilege_level, _most_privileged_role_label = role_params
      @available_roles = ordered_role_entries.select { |_role, role_tuple| role_tuple[0] <= privilege_level }
    end

    # PUT /resource
    def update
      super

      Rails.logger.info 'Role parameters', role_params:
    end
    #
    # # DELETE /resource
    # def destroy
    #   super
    # end
    #
    # # GET /resource/cancel
    # def cancel
    #   super
    # end

    protected

    def role_params
      params.permit(system_role: { user: [] })[:system_role]
    end

    # List of supported roles prioritized by their privilege level
    def ordered_role_entries
      @ordered_role_entries ||= User::SUPPORTED_ROLES.entries.sort do |(_role_a, role_a_tuple), (_role_b, role_b_tuple)|
        role_b_tuple[0] <=> role_a_tuple[0]
      end
    end

    #
    # # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: %i[given_name family_name nickname])
    # end
    #
    # # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: %i[given_name family_name nickname])
    # end
    #
    # # The path used after sign up.
    # def after_sign_up_path_for(_resource)
    #   root_path
    # end
    #
    # # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(_resource)
    #   root_path
    # end
    #
    # # The path used after sign up for inactive accounts.
    # def after_update_path_for(_resource)
    #   root_path
    # end

    private

    def calculate_global_privilege_level
      @most_privileged_role, role_params = ordered_role_entries.find { |role, _role_tuple| resource.has_role?(role) }
      @global_privilege_level, _most_privileged_role_label = role_params
    end

    def set_available_roles
      calculate_global_privilege_level unless @most_privileged_role.present?
      @available_roles ||= ordered_role_entries.select do |_role, role_tuple|
        role_tuple[0] <= global_privilege_level
      end
    end

    def assign_default_role
      resource.add_role(:user) if resource.present? && resource_supports_roles? && resource.roles.blank?
    end

    def resource_supports_roles?
      resource_name.to_s.classify.constantize::SUPPORTED_ROLES.present?
    end
  end
end
