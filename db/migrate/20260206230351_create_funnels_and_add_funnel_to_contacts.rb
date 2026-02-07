# frozen_string_literal: true

class CreateFunnelsAndAddFunnelToContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :funnels do |t|
      t.string :name, null: false
      t.references :account, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :funnels, [:account_id, :name], unique: true

    add_reference :contacts, :funnel, foreign_key: true, index: true, null: true
    add_column :contacts, :funnel_stage, :integer, default: nil
  end
end
