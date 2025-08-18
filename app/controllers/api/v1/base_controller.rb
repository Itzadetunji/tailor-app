class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  
  protected
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { error: 'Authorization token required' }, status: :unauthorized
      return
    end
    
    result = AuthService.verify_jwt_token(token)
    
    unless result[:success]
      render json: { error: result[:message] }, status: :unauthorized
      return
    end
    
    @current_user = result[:user]
  end
  
  def current_user
    @current_user
  end
end
