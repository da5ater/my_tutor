class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[ show edit update destroy ]
  before_action :set_course

  # GET /lessons or /lessons.json
  def index
    # @lessons = Lesson.all
    @lessons = @course.lessons
  end

  # GET /lessons/1 or /lessons/1.json
  def show
    authorize @lesson
    current_user&.view_lesson(@lesson)
  end

  # GET /lessons/new
  def new
    @lesson = @course.lessons.build

    authorize @lesson
  end

  # GET /lessons/1/edit
  def edit
    authorize @lesson
  end

  # POST /lessons or /lessons.json
  def create
    @lesson = @course.lessons.build(lesson_params)
    authorize @lesson
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to [ @course, @lesson ], notice: "Lesson was successfully created." }
        format.json { render :show, status: :created, location: [ @course, @lesson ] }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @lesson.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    authorize @lesson
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to [ @course, @lesson ], notice: "Lesson was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [ @course, @lesson ] }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @lesson.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    authorize @lesson
    @lesson.destroy!

    respond_to do |format|
      format.html { redirect_to course_path(@course), notice: "Lesson was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.friendly.find(params[:id])
      @course = Course.friendly.find(params[:course_id])
    end

    # Only allow a list of trusted parameters through.
    def lesson_params
      params.expect(lesson: [ :title, :content ])
    end

    def set_course
      @course = Course.friendly.find(params[:course_id])
    end
end
