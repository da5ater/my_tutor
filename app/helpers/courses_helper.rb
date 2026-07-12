module CoursesHelper

  def enrollment_button(course)
    if current_user
      if course.user == current_user
        link_to course_path(course), class: "btn btn-outline-secondary btn-sm px-3 py-2 fw-semibold rounded-pill d-inline-flex align-items-center gap-1" do
          raw("<i class='fa-solid fa-chart-line'></i> You created this course. View Analytics")
        end
      elsif course.bought?(current_user)
        link_to course_path(course), class: "btn btn-outline-success btn-sm px-3 py-2 fw-semibold rounded-pill d-inline-flex align-items-center gap-1" do
          raw("<i class='fa-solid fa-circle-check'></i> Already Enrolled. Keep Learning")
        end
      elsif course.price > 0
        link_to new_course_enrollments_path(course), class: "btn btn-success btn-sm px-3 py-2 fw-bold rounded-pill d-inline-flex align-items-center gap-1" do
          raw("<i class='fa-solid fa-cart-shopping'></i> Enroll: #{number_to_currency(course.price, precision: 0)}")
        end
      else
        link_to new_course_enrollments_path(course), class: "btn btn-success btn-sm px-3 py-2 fw-bold rounded-pill d-inline-flex align-items-center gap-1" do
          raw("<i class='fa-solid fa-graduation-cap'></i> Enroll for Free")
        end
      end
    else
      link_to new_course_enrollments_path(course), class: "btn btn-success btn-sm px-3 py-2 fw-bold rounded-pill d-inline-flex align-items-center gap-1" do
        raw("<i class='fa-solid fa-tag'></i> Check Price")
      end
    end
  end

end
