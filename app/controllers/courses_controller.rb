class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy ]
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  # GET /courses or /courses.json
  def index
        # if params[:title].present?
        #   title = Course.sanitize_sql_like(params[:title].strip)
        #   @courses = Course.where("title LIKE ?", "%#{title}%")
        # else
        #   # @courses = Course.all
        # @q = Course.ransack(params[:q])
        # @courses = @q.result.includes(:user).order(created_at: :desc)
        # if current_user.has_role?(:admin)
        @ransack_courses ||= Course.ransack(params[:courses_search], search_key: :courses_search)
       @pagy, @courses =pagy(@ransack_courses.result.includes(:user).order(created_at: :desc))
    # else
    # redirect_to root_path
    # flash[:alert] = "You are nos authorized to view this page."
    # end
    # end
  end

  # GET /courses/1 or /courses/1.json
  def show
    @lessons = @course.lessons.order(created_at: :asc)
  end

  # GET /courses/new
  def new
    @course = current_user.courses.build
  end

  # GET /courses/1/edit
  def edit
    authorize @course
  end

  # POST /courses or /courses.json
  def create
    @course = current_user.courses.build(course_params)
    authorize @course

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @course.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    authorize @course
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: "Course was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @course.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    authorize @course
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.friendly.find(params.expect(:id), allow_nil: true)
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.expect(course: [ :title, :description, :short_description, :language, :level, :price ])
    end
end
