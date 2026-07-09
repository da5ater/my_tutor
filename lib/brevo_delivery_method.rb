require "net/http"
require "json"
require "uri"

class BrevoDeliveryMethod
  def initialize(settings = {})
    @api_key = settings.fetch(:api_key)
  end

  def deliver!(mail)
    uri = URI("https://api.brevo.com/v3/smtp/email")

    payload = {
      sender: parse_address(mail[:from].to_s),
      to: mail.to.map { |email| { email: email } },
      subject: mail.subject,
      htmlContent: mail.html_part&.body&.decoded || mail.body.decoded,
      textContent: mail.text_part&.body&.decoded
    }.compact

    request = Net::HTTP::Post.new(uri)
    request["accept"] = "application/json"
    request["api-key"] = @api_key
    request["content-type"] = "application/json"
    request.body = JSON.generate(payload)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    return response if response.is_a?(Net::HTTPSuccess)

    raise "Brevo delivery failed: #{response.code} #{response.body}"
  end

  private

  def parse_address(value)
    address = Mail::Address.new(value)
    { name: address.display_name, email: address.address }.compact
  end
end
