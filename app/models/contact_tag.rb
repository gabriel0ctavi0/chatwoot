# frozen_string_literal: true

class ContactTag < ApplicationRecord
  include RegexHelper
  include AccountCacheRevalidator

  belongs_to :account

  validates :title,
            presence: { message: I18n.t('errors.validations.presence') },
            format: { with: UNICODE_CHARACTER_NUMBER_HYPHEN_UNDERSCORE },
            uniqueness: { scope: :account_id }

  default_scope { order(:title) }

  before_validation do
    self.title = title.downcase if attribute_present?('title')
  end
end
