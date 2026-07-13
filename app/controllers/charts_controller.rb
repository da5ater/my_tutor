class ChartsController < ApplicationController
  before_action :authorize_admin_dashboard
  def users_per_day
    render json: User.group_by_day(:created_at).count
  end

  def enrollments_per_day
    render json: Enrollment.group_by_day(:created_at).count
  end

  def course_popularity
    render json: Enrollment.joins(:course).group("courses.title").count
  end

  def authorize_admin_dashboard
    authorize :admin_dashboard, :show?
  end

  def moneymakers
    render json: Enrollment.joins(:course).group("courses.title").sum(:price)
  end

    def lesson_impressions
      render json: UserLesson.joins(:lesson).group("lessons.title").sum(:impressions)
    end
end
