# frozen_string_literal: true

class Api::V1::Accounts::ContactTagsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_contact_tag, except: [:index, :create]
  before_action :check_authorization

  around_action :log_contact_tags_errors

  def index
    @contact_tags = policy_scope(Current.account.contact_tags)
  end

  def show; end

  def create
    @contact_tag = Current.account.contact_tags.create!(permitted_params)
  end

  def update
    @contact_tag.update!(permitted_params)
  end

  def destroy
    @contact_tag.destroy!
    head :ok
  end

  private

  def log_contact_tags_errors
    yield
  rescue StandardError => e
    Rails.logger.error("[ContactTags] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace&.first(15)&.join("\n"))
    payload = { error: e.class.name, message: e.message }
    payload[:backtrace] = e.backtrace&.first(15) if Rails.env.development? || params[:debug]
    render json: payload, status: :internal_server_error and return
  end

  def fetch_contact_tag
    @contact_tag = Current.account.contact_tags.find(params[:id])
  end

  def permitted_params
    params.require(:contact_tag).permit(:title, :description, :color, :show_on_sidebar)
  end
end
