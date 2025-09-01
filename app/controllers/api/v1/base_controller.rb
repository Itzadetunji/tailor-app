class Api::V1::BaseController < ApplicationController
  
  # Commented out for testing - uncomment for production
  # before_action :authenticate_user!
  
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
  
  def render_success(data = nil, message = "Operation completed successfully", status = :ok)
    response = {
      success: true,
      message: message
    }
    response[:data] = data if data
    
    render json: response, status: status
  end
  
  def render_error(errors, message = "Operation failed", status = :unprocessable_entity)
    errors = [errors] unless errors.is_a?(Array)
    
    render json: {
      success: false,
      message: message,
      errors: errors
    }, status: status
  end
  
  def render_validation_errors(model, message = "Validation failed")
    render_error(model.errors.full_messages, message)
  end
  
  def render_not_found(message = "Resource not found")
    render_error([message], message, :not_found)
  end
  
  def paginate_collection(collection, per_page = 25)
    page = params[:page] || 1
    per_page = [per_page, 100].min
    
    paginated_collection = collection.page(page).per(per_page)
    
    {
      data: paginated_collection,
      pagination: {
        current_page: paginated_collection.current_page,
        total_pages: paginated_collection.total_pages,
        total_count: paginated_collection.total_count,
        per_page: paginated_collection.limit_value
      }
    }
  end
end
