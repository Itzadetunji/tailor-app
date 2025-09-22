class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :update ]

  # PATCH/PUT /api/v1/users/profile
  def update
    if @user.update(user_update_params)
      render json: {
        success: true,
        data: user_data(@user),
        message: "User updated successfully"
      }
    else
      render json: {
        success: false,
        errors: @user.errors.full_messages,
        message: "Failed to update user"
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_update_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :profession,
      :business_name,
      :business_address,
      :has_onboarded,
      skills: []
    )
  end
end
