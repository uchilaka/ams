# frozen_string_literal: true

module NavbarHelper
  include UserProfileHelper

  def navbar_version
    '1.0'
  end

  def profile_name
    @profile_name ||= current_user.nickname || current_user.given_name || current_user.email
  end

  def profile_email
    @profile_email ||= current_user.email
  end

  def profile_photo_url
    avatar_url(current_user)
  end

  def show_admin_menu?
    user_signed_in? || Rails.env.development?
  end

  def main_menu
    # TODO: Internationalize these link labels
    # TODO: Include accessibility information for screen readers
    #  and other assistive technologies
    # TODO: Include icon classes for each link
    # TODO: Use pundit policy to determine which links to display
    # TODO: Memoize and return as @main_menu after policy checks
    # TODO: Cache this menu in Redis for 1 hour
    @main_menu ||= [
      {
        label: t('shared.navbar.home'),
        path: root_path,
        enabled: true,
        public: true
      },
      {
        label: t('shared.navbar.dashboard'),
        path: pages_dashboard_path,
        enabled: true
      },
      {
        label: t('shared.navbar.accounts'),
        path: accounts_path,
        enabled: true
      },
      {
        label: t('shared.navbar.services'),
        path: services_path
      },
      # TODO: Eventually take products off this list - intended navigation
      #   is to traverse via services to the component products
      {
        label: t('shared.navbar.products'),
        path: products_path
      },
    ].map { |item| build_menu_item(item) }.filter(&:enabled)
  end

  def public_menu
    @public_menu ||= main_menu.filter(&:public)
  end

  def admin_menu
    @admin_menu ||= [
      { label: 'Products', path: '/products', admin: true, enabled: true },
      { label: 'Features', path: '/admin/flipper', admin: true, enabled: true },
      { label: 'Sidekiq', path: '/admin/sidekiq', admin: true, enabled: true },
    ].map { |item| build_menu_item(item) }.filter(&:enabled)
  end

  private

  def build_menu_item(item)
    item[:enabled] ||= calculate_enabled(item)
    item[:admin] ||= false
    item[:public] ||= false
    # Return a new Struct::NavbarItem instance
    Struct::NavbarItem.new(item)
  end

  def calculate_enabled(item)
    return true if item[:public]

    # Compose feature flag for menu item
    feat_flag = "feat__#{item[:label].to_s.parameterize(separator: '_')}".to_sym
    return Flipper.enabled?(feat_flag) if current_user.blank?

    # Check if feature flag is enabled for current user
    Flipper.enabled?(feat_flag, current_user)
  end
end
