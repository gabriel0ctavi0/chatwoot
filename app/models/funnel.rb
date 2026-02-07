# frozen_string_literal: true

class Funnel < ApplicationRecord
  belongs_to :account
  has_many :contacts, dependent: :nullify

  validates :name,
            presence: { message: I18n.t('errors.validations.presence') },
            uniqueness: { scope: :account_id }
end
