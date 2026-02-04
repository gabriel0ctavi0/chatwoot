# frozen_string_literal: true

class CreateContactTags < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_tags do |t|
      t.string :title
      t.text :description
      t.string :color, default: '#1f93ff', null: false
      t.boolean :show_on_sidebar
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :contact_tags, [:title, :account_id], unique: true
  end
end
