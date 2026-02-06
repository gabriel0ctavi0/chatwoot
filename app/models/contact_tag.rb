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

  after_destroy :remove_tag_from_contacts

  private

  def remove_tag_from_contacts
    # ActsAsTaggableOn doesn't automatically remove tags from taggable objects when the tag is deleted
    # if we are using a custom model for tags. We need to manually clean up the taggings.
    # However, since we are using acts_as_taggable_on :contact_tags, it uses the standard tagging table.
    # We need to find all contacts that have this tag and remove it.
    tag = ActsAsTaggableOn::Tag.find_by(name: title)
    return unless tag

    ActsAsTaggableOn::Tagging.where(tag_id: tag.id, taggable_type: 'Contact', context: 'contact_tags').destroy_all
  end
end
