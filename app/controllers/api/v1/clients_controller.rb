class Api::V1::ClientsController < Api::V1::BaseController
  before_action :set_client, only: [:show, :update]
  
  # GET /api/v1/clients
  def index
    include_trashed = params[:include_trashed] == 'true'
    per_page = [params[:per_page].to_i, 100].min
    per_page = 25 if per_page <= 0
    
    clients = include_trashed ? Client.all : Client.active
    clients = clients.includes(:client_custom_field_values, :custom_fields)
                    .order(:name)
    
    result = paginate_collection(clients, per_page)
    
    serialized_clients = result[:data].map do |client|
      ClientSerializer.new(client, include: [:custom_fields]).serializable_hash
    end
    
    render_success({
      clients: serialized_clients,
      pagination: result[:pagination]
    })
  end
  
  # GET /api/v1/clients/:id
  def show
    serialized_client = ClientSerializer.new(@client, include: [:custom_fields]).serializable_hash
    render_success(serialized_client)
  end
  
  # POST /api/v1/clients
  def create
    @client = Client.new(client_params)
    
    if @client.save
      # Handle custom fields
      handle_custom_fields(@client, params[:client][:custom_fields]) if params[:client][:custom_fields]
      
      serialized_client = ClientSerializer.new(@client.reload, include: [:custom_fields]).serializable_hash
      render_success(serialized_client, "Client created successfully", :created)
    else
      render_validation_errors(@client)
    end
  end
  
  # PATCH /api/v1/clients/:id
  def update
    if @client.update(client_params)
      # Handle custom fields
      handle_custom_fields(@client, params[:client][:custom_fields]) if params[:client][:custom_fields]
      
      serialized_client = ClientSerializer.new(@client.reload, include: [:custom_fields]).serializable_hash
      render_success(serialized_client, "Client updated successfully")
    else
      render_validation_errors(@client)
    end
  end
  
  # DELETE /api/v1/clients/bulk_delete
  def bulk_delete
    client_ids = params[:client_ids]
    
    if client_ids.blank? || !client_ids.is_a?(Array)
      render_error(["Client IDs must be provided as an array"], "Invalid parameters", :bad_request)
      return
    end
    
    # Validate UUIDs
    invalid_ids = client_ids.reject { |id| valid_uuid?(id) }
    if invalid_ids.any?
      render_error(["Invalid UUID format for IDs: #{invalid_ids.join(', ')}"], "Invalid parameters", :bad_request)
      return
    end
    
    begin
      affected_count = Client.bulk_soft_delete(client_ids)
      render_success(
        { affected_count: affected_count },
        "#{affected_count} client(s) moved to trash successfully"
      )
    rescue StandardError => e
      render_error([e.message], "Failed to delete clients", :internal_server_error)
    end
  end
  
  private
  
  def set_client
    @client = Client.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Client not found")
  end
  
  def client_params
    params.require(:client).permit(
      :name, :gender, :measurement_unit, :phone_number, :email,
      :ankle, :bicep, :bottom, :chest, :head, :height, :hip, :inseam,
      :knee, :neck, :outseam, :shorts, :shoulder, :sleeve, :short_sleeve,
      :thigh, :top_length, :waist, :wrist
    )
  end
  
  def handle_custom_fields(client, custom_fields_params)
    return unless custom_fields_params.is_a?(Hash)
    
    custom_fields_params.each do |custom_field_id, value|
      next if value.blank?
      
      custom_field = CustomField.active.find_by(id: custom_field_id)
      next unless custom_field
      
      client.set_custom_field_value(custom_field, value)
    end
  end
  
  def valid_uuid?(string)
    uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    !!(string =~ uuid_regex)
  end
end
