require "exception_notification/rails"
require "exception_notification/rake"

if Rails.env.production?
  ExceptionNotification.configure do |config|
    config.add_notifier :email, {
      email_prefix: "[Tutor Error] ",
      sender_address: ENV["MAILER_SENDER"],
      exception_recipients: [ ENV["EXCEPTION_RECIPIENT"] ]
    }
  end
end
