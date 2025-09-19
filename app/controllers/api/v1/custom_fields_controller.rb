class Api::V1::CustomFieldsController < Api::V1::BaseController
  before_action :set_custom_field, only: [ :show, :update, :destroy ]

  # GET /api/v1/custom_fields
  def index
    custom_fields = CustomField.all
    is_active = params[:is_active]

    if is_active.present?
      is_active = ActiveModel::Type::Boolean.new.cast(is_active) # THis is to convert the value to a boolean
      custom_fields = is_active ? CustomField.active : CustomField.inactive
    end

    custom_fields = custom_fields.order(:field_name)

    serialized_fields = custom_fields.map do |field|
      CustomFieldSerializer.new(field).serializable_hash
    end

    render_success(serialized_fields)
  end

  # GET /api/v1/custom_fields/:id
  def show
    serialized_field = CustomFieldSerializer.new(@custom_field).serializable_hash
    render_success(serialized_field)
  end

  # POST /api/v1/custom_fields
  def create
    @custom_field = CustomField.new(custom_field_params)

    if @custom_field.save
      serialized_field = CustomFieldSerializer.new(@custom_field).serializable_hash
      render_success(serialized_field, "Custom field created successfully", :created)
    else
      render_validation_errors(@custom_field)
    end
  end

  # PATCH /api/v1/custom_fields/:id
  def update
    if @custom_field.update(custom_field_params)
      serialized_field = CustomFieldSerializer.new(@custom_field).serializable_hash
      render_success(serialized_field, "Custom field updated successfully")
    else
      render_validation_errors(@custom_field)
    end
  end

  # DELETE /api/v1/custom_fields/:id
  def destroy
    @custom_field.update!(is_active: false)
    render_success(nil, "Custom field deactivated successfully")
  rescue StandardError => e
    render_error([ e.message ], "Failed to deactivate custom field")
  end

  private

  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Custom field not found")
  end

  def custom_field_params
    params.require(:custom_field).permit(:field_name, :field_type, :is_active)
  end
end
