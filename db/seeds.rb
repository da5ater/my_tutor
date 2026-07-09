user = User.find_or_create_by!(email: "mohamed@example.com") do |u|
  u.password = "123456"
  u.password_confirmation = "123456"
end

Course.destroy_all

30.times do
  Course.create!(title: Faker::Educator.course_name, description: Faker::Hacker.say_something_smart, user: user)
end
