class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[ show edit update destroy ]
  before_action :set_course, only: %i[new create]

  # GET /enrollments or /enrollments.json
  def index
    @q = Enrollment.ransack(params[:q])
    @pagy, @enrollments = pagy(@q.result.includes(:user, :course))
    authorize @enrollments
  end

  # GET /enrollments/1 or /enrollments/1.json
  def show
  end

  # GET /enrollments/new
  def new
    authorize @course, :enroll?
    @enrollment = Enrollment.new
  end

  # GET /enrollments/1/edit
  def edit
    authorize @enrollment
  end

  # POST /enrollments or /enrollments.json
  def create
    authorize @course, :enroll?

    if @course.price > 0
      flash[:alert] = "in development"
      redirect_to new_course_enrollment_path(@course)
    else
      @enrollment = current_user.buy_course(@course)
      redirect_to course_path(@course), notice: "You are enrolled in this course"
    end
  end

  # PATCH/PUT /enrollments/1 or /enrollments/1.json
  def update
    authorize @enrollment
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        format.html { redirect_to course_path(@enrollment.course), notice: "Enrollment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @enrollment.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /enrollments/1 or /enrollments/1.json
  def destroy
    authorize @enrollment
    @enrollment.destroy!

    respond_to do |format|
      format.html { redirect_to enrollments_path, notice: "Enrollment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def my_students
    @ransack_path = my_students_enrollments_path

    @q = Enrollment.joins(:course).where(courses: { user_id: current_user.id }).ransack(params[:q])
    @pagy, @enrollments = pagy(@q.result.includes(:user, :course).order(created_at: :desc))
    render :index
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enrollment
      @enrollment = Enrollment.friendly.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def enrollment_params
      params.expect(enrollment: [ :rating, :review ])
    end

    def set_course
      @course = Course.friendly.find(params.expect(:course_id))
    end
end
