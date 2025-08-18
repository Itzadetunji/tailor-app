class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'fallback_secret_key'
  
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
  
  def self.valid_payload?(payload)
    payload && payload[:exp] && Time.at(payload[:exp]) > Time.current
  end
end
