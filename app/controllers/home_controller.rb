class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    public_courses = Course.publicly_available
    @courses = public_courses.order(created_at: :desc).limit(3)
    @courses_count = public_courses.count
    @instructors_count = User.joins(:courses).merge(public_courses).distinct.count
    @users_count = User.count
    @purchased_courses = current_user ? Course.joins(:enrollments).where(enrollments: { user_id: current_user.id }).order(created_at: :desc).limit(3) : []

    @latest_courses = public_courses.latest
    @popular_courses = public_courses.popular
    @top_rated_courses = public_courses.top_rated
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
