require "cgi"
require "json"
require "net/http"
require "uri"

if Rails.env.production? && ENV["DEMO_RESET"] != "1"
  abort "Refusing to replace production data without DEMO_RESET=1"
end

catalog_uri = URI("https://learn.microsoft.com/api/catalog/?locale=en-us&type=learningPaths,modules")
catalog_response = Net::HTTP.start(
  catalog_uri.host,
  catalog_uri.port,
  use_ssl: true,
  open_timeout: 10,
  read_timeout: 45
) do |http|
  request = Net::HTTP::Get.new(catalog_uri)
  request["Accept"] = "application/json"
  request["User-Agent"] = "MyTutorDemoSeeder/1.0"
  http.request(request)
end

unless catalog_response.is_a?(Net::HTTPSuccess)
  abort "Microsoft Learn catalog request failed with HTTP #{catalog_response.code}"
end

catalog = JSON.parse(catalog_response.body)
paths_by_uid = catalog.fetch("learningPaths").index_by { |path| path.fetch("uid") }
modules_by_uid = catalog.fetch("modules").index_by { |course_module| course_module.fetch("uid") }

course_blueprints = [
  {
    uid: "learn.github-foundations",
    price: 49,
    owner: 0,
    published: true,
    approved: true
  },
  {
    uid: "learn.wwl.build-web-pages-html-css-for-beginners",
    price: 39,
    owner: 1,
    published: true,
    approved: true
  },
  {
    uid: "learn.aspnet-core-web-app",
    price: 69,
    owner: 2,
    published: true,
    approved: true
  },
  {
    uid: "learn.accessibility-fundamental",
    price: 0,
    owner: 3,
    published: true,
    approved: true
  },
  {
    uid: "learn.wwl.devops-foundations-core-principles-practices",
    price: 79,
    owner: 0,
    published: true,
    approved: true
  },
  {
    uid: "learn.wwl.understand-data-concepts",
    price: 59,
    owner: 1,
    published: true,
    approved: true
  },
  {
    uid: "learn.wwl.develop-generative-ai-apps",
    price: 99,
    owner: 2,
    published: true,
    approved: true
  },
  {
    uid: "learn.wwl.implement-security-through-pipeline-using-devops",
    price: 89,
    owner: 3,
    published: true,
    approved: true
  },
  {
    uid: "learn.languages.fsharp-first-steps",
    price: 45,
    owner: 0,
    published: true,
    approved: false
  },
  {
    uid: "learn.intro-to-inclusive-design-practice",
    price: 35,
    owner: 1,
    published: false,
    approved: false
  }
].freeze

missing_paths = course_blueprints.filter_map { |blueprint| blueprint[:uid] unless paths_by_uid.key?(blueprint[:uid]) }
abort "Microsoft Learn paths are missing: #{missing_paths.join(", ")}" if missing_paths.any?

missing_modules = course_blueprints.flat_map do |blueprint|
  paths_by_uid.fetch(blueprint[:uid]).fetch("modules").reject { |uid| modules_by_uid.key?(uid) }
end.uniq
abort "Microsoft Learn modules are missing: #{missing_modules.join(", ")}" if missing_modules.any?

admin_email = ENV.fetch("DEMO_ADMIN_EMAIL", "portfolio.admin@mytutor-demo.com")
admin_password = ENV["DEMO_ADMIN_PASSWORD"].presence
demo_password = ENV["DEMO_USER_PASSWORD"].presence
if Rails.env.production? && (admin_password.blank? || demo_password.blank?)
  abort "DEMO_ADMIN_PASSWORD and DEMO_USER_PASSWORD must be set when seeding production"
end
admin_password ||= "MyTutorDemo!2026"
demo_password ||= "LearnerDemo!2026"
now = Time.current

people = [
  { email: admin_email, roles: %i[admin teacher student], created_at: now - 118.days },
  { email: "salma.hassan@mytutor-demo.com", roles: %i[teacher student], created_at: now - 111.days },
  { email: "omar.khalil@mytutor-demo.com", roles: %i[teacher student], created_at: now - 103.days },
  { email: "nour.elmasry@mytutor-demo.com", roles: %i[teacher student], created_at: now - 94.days },
  { email: "youssef.fahmy@mytutor-demo.com", roles: %i[teacher student], created_at: now - 86.days },
  { email: "mariam.adel@mytutor-demo.com", roles: %i[student], created_at: now - 76.days },
  { email: "ahmed.samir@mytutor-demo.com", roles: %i[student], created_at: now - 67.days },
  { email: "jana.ali@mytutor-demo.com", roles: %i[student], created_at: now - 55.days },
  { email: "karim.nabil@mytutor-demo.com", roles: %i[student], created_at: now - 43.days },
  { email: "farah.mahmoud@mytutor-demo.com", roles: %i[student], created_at: now - 31.days },
  { email: "hassan.tarek@mytutor-demo.com", roles: %i[student], created_at: now - 20.days },
  { email: "lina.mostafa@mytutor-demo.com", roles: %i[student], created_at: now - 8.days }
].freeze

reviews = [
  "The sequence was easy to follow, and each module built naturally on the previous one.",
  "Practical and well paced. I could apply the main ideas to a small project immediately.",
  "The examples made a difficult topic approachable without oversimplifying it.",
  "A strong introduction with enough depth to make the next steps clear.",
  "The curriculum is focused and useful. I especially liked the short, purposeful modules.",
  "Clear explanations and a good balance between concepts and hands-on practice.",
  "I came in with gaps in the fundamentals and finished with a much clearer mental model.",
  "Useful structure and realistic examples. I would recommend it to another self-taught developer."
].freeze

PublicActivity.enabled = false

ActiveRecord::Base.transaction do
  PublicActivity::Activity.delete_all
  UserLesson.delete_all
  Enrollment.delete_all
  Course.update_all(enrollments_count: 0)
  Lesson.destroy_all
  Course.destroy_all
  User.destroy_all
  Role.destroy_all
  FriendlyId::Slug.delete_all

  users = people.map.with_index do |person, index|
    password = index.zero? ? admin_password : demo_password
    user = User.new(
      email: person.fetch(:email),
      password: password,
      password_confirmation: password,
      created_at: person.fetch(:created_at),
      updated_at: person.fetch(:created_at),
      confirmed_at: person.fetch(:created_at),
      sign_in_count: (index * 3) + 1,
      last_sign_in_at: [ person.fetch(:created_at) + 2.days, now - (index + 2).hours ].min,
      current_sign_in_at: [ person.fetch(:created_at) + 3.days, now - (index + 1).hours ].min
    )
    user.skip_confirmation!
    user.save!
    user.roles.clear
    person.fetch(:roles).each { |role| user.add_role(role) }
    user
  end

  teachers = users.select { |user| user.has_role?(:teacher) && !user.has_role?(:admin) }

  courses = course_blueprints.map.with_index do |blueprint, course_index|
    source_path = paths_by_uid.fetch(blueprint.fetch(:uid))
    source_url = source_path.fetch("url")
    source_summary = source_path.fetch("summary").to_s.squish
    module_count = source_path.fetch("modules").size
    duration = source_path.fetch("duration_in_minutes", 0)
    created_at = now - (82 - (course_index * 6)).days

    description = <<~HTML
      <p>#{CGI.escapeHTML(source_summary)}</p>
      <p><strong>Curriculum:</strong> #{module_count} modules, approximately #{duration} minutes of guided learning.</p>
      <p><em>Course metadata comes from the public Microsoft Learn catalog. The instructor, price, reviews, and learner activity are portfolio demo data.</em></p>
      <p><a href="#{CGI.escapeHTML(source_url)}" target="_blank" rel="noopener noreferrer">View the original Microsoft Learn path</a></p>
    HTML

    course = Course.create!(
      title: source_path.fetch("title"),
      short_description: source_summary.truncate(190),
      description: description,
      language: "English",
      level: source_path.fetch("levels", [ "beginner" ]).first.to_s.capitalize,
      price: blueprint.fetch(:price),
      user: teachers.fetch(blueprint.fetch(:owner)),
      published: blueprint.fetch(:published),
      approved: blueprint.fetch(:approved),
      created_at: created_at,
      updated_at: [ created_at + 12.days, now - 2.days ].min
    )

    source_path.fetch("modules").each.with_index do |module_uid, lesson_index|
      source_module = modules_by_uid.fetch(module_uid)
      module_url = source_module.fetch("url")
      module_summary = source_module.fetch("summary").to_s.squish
      module_duration = source_module.fetch("duration_in_minutes", 0)
      lesson_created_at = created_at + (lesson_index + 1).days
      content = <<~HTML
        <p>#{CGI.escapeHTML(module_summary)}</p>
        <p><strong>Estimated study time:</strong> #{module_duration} minutes.</p>
        <p>This demo tracks this module as a lesson. Complete the learning material on Microsoft Learn, then return here to continue through the course.</p>
        <p><a href="#{CGI.escapeHTML(module_url)}" target="_blank" rel="noopener noreferrer">Open this module on Microsoft Learn</a></p>
      HTML

      Lesson.create!(
        course: course,
        title: source_module.fetch("title"),
        content: content,
        created_at: lesson_created_at,
        updated_at: lesson_created_at
      )
    end

    course
  end

  public_courses = courses.select(&:publicly_available?)
  students = users.select { |user| user.has_role?(:student) && !user.has_role?(:teacher) }
  progress_steps = [ 0.0, 0.25, 0.5, 0.75, 1.0 ].freeze

  public_courses.each.with_index do |course, course_index|
    students.each.with_index do |student, student_index|
      next unless ((course_index * 2) + student_index) % 5 < 3

      days_ago = 52 - ((course_index * 7 + student_index * 4) % 49)
      enrolled_at = now - days_ago.days - ((student_index * 2) % 10).hours
      discount = [ 0, 0, 5, 10, 15 ].fetch((course_index + student_index) % 5)
      paid_price = [ course.price - discount, 0 ].max
      reviewed = (course_index + student_index) % 4 != 0

      enrollment = Enrollment.create!(
        course: course,
        user: student,
        price: paid_price,
        rating: reviewed ? [ 4, 5, 5, 3, 4 ].fetch((course_index + student_index) % 5) : nil,
        review: reviewed ? reviews.fetch((course_index * 3 + student_index) % reviews.length) : nil,
        created_at: enrolled_at,
        updated_at: reviewed ? [ enrolled_at + 9.days, now - 1.day ].min : enrolled_at
      )

      progress = progress_steps.fetch((course_index + student_index * 2) % progress_steps.length)
      viewed_lessons = (course.lessons.size * progress).ceil

      course.lessons.order(:created_at).first(viewed_lessons).each.with_index do |lesson, lesson_index|
        viewed_at = [ enrollment.created_at + (lesson_index + 1).days, now - 3.hours ].min
        UserLesson.create!(
          user: student,
          lesson: lesson,
          impressions: 1 + ((course_index * 5 + student_index * 3 + lesson_index * 2) % 18),
          created_at: viewed_at,
          updated_at: viewed_at
        )
      end
    end
  end

  courses.each do |course|
    Course.reset_counters(course.id, :lessons, :enrollments)
    course.reload.update_rating
  end
  users.each { |user| User.reset_counters(user.id, :courses, :enrollments) }

  activity_courses = courses.first(8)
  activity_courses.each.with_index do |course, index|
    PublicActivity::Activity.create!(
      key: index.even? ? "course.create" : "course.update",
      owner: course.user,
      trackable: course,
      created_at: now - (index + 1).days,
      updated_at: now - (index + 1).days
    )
  end
end

PublicActivity.enabled = true

puts "Demo catalog imported from Microsoft Learn."
puts "Created #{User.count} users, #{Course.count} courses, #{Lesson.count} lessons, #{Enrollment.count} enrollments, and #{UserLesson.sum(:impressions)} lesson impressions."
puts "Admin login: #{admin_email}"
