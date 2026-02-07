# frozen_string_literal: true

class Api::V1::Accounts::FunnelsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_funnel, except: [:index, :create]
  before_action :check_authorization

  def index
    @funnels = policy_scope(Current.account.funnels)
  end

  def show; end

  def create
    @funnel = Current.account.funnels.create!(permitted_params)
  end

  def update
    @funnel.update!(permitted_params)
  end

  def destroy
    @funnel.destroy!
    head :ok
  end

  def contacts
    @contacts = @funnel.contacts.includes(:company).order(:funnel_stage, updated_at: :desc)
    @contacts = @contacts.where(funnel_stage: params[:stage]) if params[:stage].present?
  end

  def move_contact
    contact = Current.account.contacts.find(params[:contact_id])
    contact.update!(funnel_id: @funnel.id, funnel_stage: params[:stage])
    render json: { success: true, contact_id: contact.id, funnel_id: @funnel.id, funnel_stage: contact.funnel_stage }
  end

  private

  def fetch_funnel
    @funnel = Current.account.funnels.find(params[:id])
  end

  def permitted_params
    params.require(:funnel).permit(:name)
  end
end
