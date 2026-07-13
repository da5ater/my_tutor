class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    @courses = Course.order(created_at: :desc).limit(3)
    @latest_courses = Course.order(created_at: :desc).limit(3)
    @courses_count = Course.count
    @instructors_count = User.joins(:courses).distinct.count
    @users_count = User.count
    @purchased_courses = current_user ? Course.joins(:enrollments).where(enrollments: { user_id: current_user.id }).order(created_at: :desc).limit(3) : []
    @popular_courses = Course.order(enrollments_count: :desc, created_at: :desc).limit(3)
    @top_rated_courses = Course.order(average_rating: :desc, created_at: :desc).limit(3)
    @latest_good_reviews = Enrollment.reviewed.order(rating: :desc, created_at: :desc).limit(3)
  end

  def activity
    @activities = PublicActivity::Activity.order(created_at: :desc).all
  end
end
