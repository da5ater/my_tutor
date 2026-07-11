Course.destroy_all
User.destroy_all
Role.destroy_all

Role.create!([
  { name: "admin" },
  { name: "teacher" },
  { name: "student" }
])

# Create Mohamed manually
mohamed = User.new(
  email: "admin@example.com",
  password: "adminadmin",
  password_confirmation: "adminadmin"
  )

  mohamed.skip_confirmation!
  mohamed.save!

  mohamed.add_role(:admin)
  mohamed.add_role(:teacher)
  mohamed.add_role(:student)

  users = [ mohamed ]

  # Create four additional users with Faker
  4.times do
    user = User.new(
      email: Faker::Internet.unique.email,
      password: "123456",
      password_confirmation: "123456"
      )

      user.skip_confirmation!
      user.save!
      users << user
    end

30.times do |index|
  title = "#{Faker::Educator.course_name} #{index + 1}"

  Course.create!(
    title: title,
    description: Faker::Hacker.say_something_smart,
    short_description: Faker::Educator.course_name,
    language: Course.languages.sample.first,
    level: Course.levels.sample.first,
    price: Faker::Number.between(from: 50, to: 500),
    slug: title.parameterize,
    user: users.sample
    )
  end


  PublicActivity::Activity.destroy_all
