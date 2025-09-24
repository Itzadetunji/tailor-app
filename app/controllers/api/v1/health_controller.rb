class Api::V1::HealthController < ApplicationController
  include UserDataConcern

  # Health check endpoint - authentication is optional
  def check
    # Try to authenticate user if token is provided, but don't fail if not
    user_info = nil

    if request.headers["Authorization"].present?
      token = request.headers["Authorization"]&.split(" ")&.last

      if token.present?
        result = AuthService.verify_jwt_token(token)
        if result[:success]
          user_info = user_data(result[:user])
        end
      end
    end

    render json: {
      status: "ok",
      message: "Server is running and healthy",
      timestamp: Time.current.iso8601,
      user: user_info
    }, status: :ok
  end
end
