class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy ]
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  # GET /courses or /courses.json
  def index
    if params[:title].present?
      title = Course.sanitize_sql_like(params[:title].strip)
      @courses = Course.where("title LIKE ?", "%#{title}%")
    else
      @courses = Course.all
    end
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = current_user.courses.build
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  def create
    @course = current_user.courses.build(course_params)

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
