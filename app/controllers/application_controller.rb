class ApplicationController < ActionController::API
	rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error

	private

	def handle_parse_error(exception)
		render json: { error: 'Malformed request body' }, status: :bad_request
	end
end
