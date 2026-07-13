class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    @courses = Course.order(created_at: :desc).limit(3)
    @courses_count = Course.count
    @instructors_count = User.joins(:courses).distinct.count
    @users_count = User.count
    @purchased_courses = current_user ? Course.joins(:enrollments).where(enrollments: { user_id: current_user.id }).order(created_at: :desc).limit(3) : []

    @latest_courses = Course.latest
    @popular_courses = Course.popular
    @top_rated_courses = Course.top_rated
    @latest_good_reviews = Enrollment.reviewed.latest_good_reviews
  end

  def analytics
    authorize :admin_dashboard, :show?

    @users_count = User.count
    @enrollments_count = Enrollment.count
    @active_courses_count = Enrollment.distinct.count(:course_id)
  end


  def activity
     authorize :admin_dashboard, :show?
    @activities = PublicActivity::Activity.order(created_at: :desc).all
  end
end
