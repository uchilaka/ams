# frozen_string_literal: true

# 20240224132155_create_products.rb
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :sku
      t.string :display_name, null: false
      t.string :type, null: false
      t.json :data
      t.uuid :vendor_id
      t.foreign_key :accounts, column: :vendor_id, type: :uuid

      t.timestamps
    end
  end
end
