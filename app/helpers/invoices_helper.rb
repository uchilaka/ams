# frozen_string_literal: true

module InvoicesHelper
  def invoice_filtering_enabled?
    Flipper.enabled?(:feat__invoice_filtering)
  end

  def due_date_filter_options
    [
      ['Past due 7 days', 'past_due_7_days'],
      ['Past due 30 days', 'past_due_30_days'],
      ['Past due later', 'past_due_later_than_30_days'],
      ['Due today', 'due_today'],
      ['Due this week', 'due_this_week'],
      ['Due this month', 'due_this_month'],
      ['Due next month', 'due_next_month'],
      ['Due later', 'due_later_than_next_month']
    ]
  end

  def invoice_status_filter_options
    [
      %w[Draft draft],
      %w[Sent sent],
      %w[Paid paid],
      %w[Cancelled cancelled]
    ]
  end
end
