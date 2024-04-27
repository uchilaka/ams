# frozen_string_literal: true

class AddSlugToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :slug, :string
  end
end
