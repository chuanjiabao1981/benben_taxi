class Api::V1::TaxiRequestsController < Api::ApiController
	def create
		taxi_request = TaxiRequest.build_taxi_request(params[:taxi_request],current_user)
		if taxi_request.save
			render json: json_add_data(:id,taxi_request.id)
		else
			render json: json_errors(taxi_request.errors)
		end
	end
	def index
		r = TaxiRequest.get_latest_taxi_requests(params)
		return render json: r
	end

	def answer
		if current_resource.driver_response(params[:taxi_response],current_user)
			render json: @current_resource.as_json(only:[:id,:state,:timeout])
		else
			render json: json_errors(@current_resource.errors)
		end
	end

	private 
	def current_resource

		@current_resource ||= TaxiRequest.find(params[:id]) if params[:id]
	end

end
