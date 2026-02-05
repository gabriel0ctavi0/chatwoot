# frozen_string_literal: true

class Api::V1::Accounts::ContactTagsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_contact_tag, except: [:index, :create]
  before_action :check_authorization

  # #region agent log
  around_action :log_contact_tags_errors
  # #endregion

  def index
    # #region agent log
    debug_log_contact_tags('index_entry', action: 'index', account_user_set: Current.account_user.present?)
    # #endregion
    @contact_tags = policy_scope(Current.account.contact_tags)
    # #region agent log
    debug_log_contact_tags('index_after_scope', action: 'index', count: @contact_tags.size)
    # #endregion
  end

  def show; end

  def create
    # #region agent log
    debug_log_contact_tags('create_entry', action: 'create', params_keys: params.keys, has_contact_tag: params.key?(:contact_tag))
    # #endregion
    @contact_tag = Current.account.contact_tags.create!(permitted_params)
    # #region agent log
    debug_log_contact_tags('create_success', action: 'create', id: @contact_tag.id)
    # #endregion
  end

  def update
    @contact_tag.update!(permitted_params)
  end

  def destroy
    @contact_tag.destroy!
    head :ok
  end

  private

  # #region agent log
  DEBUG_LOG_PATH = Rails.root.join('.cursor/debug.log').to_s.freeze

  def log_contact_tags_errors
    yield
  rescue StandardError => e
    Rails.logger.error("[ContactTags] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace&.first(15)&.join("\n"))
    payload = { error: e.class.name, message: e.message }
    payload[:backtrace] = e.backtrace&.first(15) if Rails.env.development? || params[:debug]
    render json: payload, status: :internal_server_error and return
  end

  def debug_log_contact_tags(msg, data = {})
    File.open(DEBUG_LOG_PATH, 'a') do |f|
      f.puts({
        timestamp: Time.now.to_i,
        location: 'contact_tags_controller',
        message: msg,
        hypothesisId: 'H_flow',
        data: data,
        sessionId: 'debug-session'
      }.to_json)
    end
  end
  # #endregion

  def fetch_contact_tag
    @contact_tag = Current.account.contact_tags.find(params[:id])
  end

  def permitted_params
    params.require(:contact_tag).permit(:title, :description, :color, :show_on_sidebar)
  end
end
