class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || "fallback_secret_key"

  def self.encode(payload, exp = 12.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    return nil if token.blank?

    begin
      body = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidSignature => e
      Rails.logger.warn "JWT decode error: #{e.message}"
      nil
    rescue => e
      Rails.logger.error "Unexpected JWT decode error: #{e.message}"
      nil
    end
  end

  def self.valid_payload?(payload)
    payload && payload[:exp] && Time.at(payload[:exp]) > Time.current
  end
end
