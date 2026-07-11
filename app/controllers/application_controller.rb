class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes



  before_action :authenticate_user!

  before_action :set_global_variables, if: :user_signed_in?

  after_action :user_activity

  def set_global_variables
    @ransack_courses = Course.ransack(params[:courses_search], search_key: :courses_search)
  end

  include PublicActivity::StoreController


  include Pundit::Authorization



  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_activity
    current_user.try :touch
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to(root_path)
  end
end
