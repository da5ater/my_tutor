class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    @courses = Course.order(created_at: :desc).limit(3)
    @latest_courses = Course.order(created_at: :desc).limit(3)
    @courses_count = Course.count
    @instructors_count = User.joins(:courses).distinct.count
    @users_count = User.count
  end
end
