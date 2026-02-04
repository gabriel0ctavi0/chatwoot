# frozen_string_literal: true

class Api::V1::Accounts::ContactTagsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_contact_tag, except: [:index, :create]
  before_action :check_authorization

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

  def fetch_contact_tag
    @contact_tag = Current.account.contact_tags.find(params[:id])
  end

  def permitted_params
    params.require(:contact_tag).permit(:title, :description, :color, :show_on_sidebar)
  end
end
