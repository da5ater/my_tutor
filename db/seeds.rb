user = User.find_or_create_by!(email: "mohamed@example.com") do |u|
  u.password = "123456"
  u.password_confirmation = "123456"
  u.skip_confirmation!
end

Course.destroy_all

30.times do
  Course.create!(
    title: Faker::Educator.course_name,
    description: Faker::Hacker.say_something_smart,
    user: user,
    short_description: Faker::Educator.course_name,
    language: "English",
    level: "Beginner",
    price: 100,
    slug: Faker::Educator.course_name.parameterize
  )
end
