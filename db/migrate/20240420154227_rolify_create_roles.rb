# frozen_string_literal: true

# 20240420154227_rolify_create_roles.rb
class RolifyCreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table(:roles, id: :uuid) do |t|
      t.string :name
      t.references :resource, polymorphic: true

      t.timestamps
    end

    create_table(:users_roles, id: false) do |t|
      t.references :user, type: :uuid
      t.references :role, type: :uuid
    end

    create_table(:accounts_roles, id: false) do |t|
      t.references :account, type: :uuid
      t.references :role, type: :uuid
    end

    add_index(:roles, %i[name resource_type resource_id])
    add_index(:users_roles, %i[user_id role_id])
    add_index(:accounts_roles, %i[account_id role_id])
  end
end
