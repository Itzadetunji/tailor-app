class AuthService
  def self.authenticate_user!(email, first_name = nil, last_name = nil)
    user = User.find_by(email: email.downcase)
    
    # Create user if they don't exist and we have their name
    if user.nil? && first_name.present? && last_name.present?
      user = User.create!(
        email: email.downcase,
        first_name: first_name,
        last_name: last_name
      )
    end
    
    return { success: false, message: 'User not found' } unless user
    
    # Generate auth code
    auth_code = user.generate_auth_code!
    
    {
      success: true,
      user: user,
      auth_code: auth_code,
      message: 'Authentication code generated successfully'
    }
  end
  
  def self.verify_code(code)
    auth_code = AuthCode.valid_codes.find_by(code: code)
    
    return { success: false, message: 'Invalid or expired code' } unless auth_code
    
    # Mark code as used
    auth_code.use!
    
    # Generate JWT token
    token = JwtService.encode({ user_id: auth_code.user.id })
    
    {
      success: true,
      user: auth_code.user,
      token: token,
      message: 'Authentication successful'
    }
  end
  
  def self.verify_magic_link(token)
    auth_code = AuthCode.valid_codes.find_by(token: token)
    
    return { success: false, message: 'Invalid or expired magic link' } unless auth_code
    
    # Mark code as used
    auth_code.use!
    
    # Generate JWT token
    jwt_token = JwtService.encode({ user_id: auth_code.user.id })
    
    {
      success: true,
      user: auth_code.user,
      token: jwt_token,
      message: 'Authentication successful'
    }
  end
  
  def self.verify_jwt_token(token)
    payload = JwtService.decode(token)
    
    return { success: false, message: 'Invalid token' } unless payload && JwtService.valid_payload?(payload)
    
    user = User.find_by(id: payload[:user_id])
    
    return { success: false, message: 'User not found' } unless user
    
    {
      success: true,
      user: user,
      message: 'Token valid'
    }
  end
end
