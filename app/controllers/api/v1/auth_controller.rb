class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [ :profile, :logout ] # This is basically a middleware

  # POST /api/v1/auth/request_magic_link
  def request_magic_link
    email = params[:email]&.strip&.downcase

    if email.blank?
      render json: { error: "Email is required" }, status: :bad_request
      return
    end

    # Authenticate or create user
    result = AuthService.authenticate_user!(email)

    if !result[:success]
      render json: { error: result[:message] }, status: :unprocessable_entity
      return
    end

    # Send magic link email
    email_result = EmailService.send_magic_link(
      result[:user],
      result[:auth_code],
      request.base_url
    )

    render json: {
      message: "Magic link sent successfully",
      debug: Rails.env.development? ? {
        code: email_result[:code],
        magic_link: email_result[:magic_link]
      } : nil
    }
  end

  # POST /api/v1/auth/verify_code
  def verify_code
    code = params[:code]&.strip

    if code.blank?
      render json: { error: "Code is required" }, status: :bad_request
      return
    end

    result = AuthService.verify_code(code)

    if result[:success]
      render json: {
        message: result[:message],
        token: result[:token],
        user: {
          id: result[:user].id,
          email: result[:user].email,
          first_name: result[:user].first_name,
          last_name: result[:user].last_name,
          full_name: result[:user].full_name
        }
      }
    else
      render json: { error: result[:message] }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/auth/verify (magic link endpoint)
  def verify_magic_link
    token = params[:token]

    if token.blank?
      render json: { error: "Token is required" }, status: :bad_request
      return
    end

    result = AuthService.verify_magic_link(token)

    if result[:success]
      render json: {
        message: result[:message],
        token: result[:token],
        user: {
          id: result[:user].id,
          email: result[:user].email,
          first_name: result[:user].first_name,
          last_name: result[:user].last_name,
          full_name: result[:user].full_name
        }
      }
    else
      render json: { error: result[:message] }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/auth/profile
  def profile
    render json: {
      user: {
        id: current_user.id,
        email: current_user.email,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        full_name: current_user.full_name
      }
    }
  end

  # DELETE /api/v1/auth/logout
  def logout
    # Remove token server-side by deleting the token record
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.present?
      token_record = Token.find_by(token: token)
      token_record&.destroy
    end

    render json: { message: "Logged out successfully" }
  end

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      render json: { error: "Authorization token required" }, status: :unauthorized
      return
    end

    result = AuthService.verify_jwt_token(token)

    unless result[:success]
      render json: { error: result[:message] }, status: :unauthorized
      return
    end

    @current_user = result[:user] # This is jsut like a middleware in nodejs so that the current_user can be accessed once initialized in the HTTP request
  end

  def current_user
    @current_user
  end
end
