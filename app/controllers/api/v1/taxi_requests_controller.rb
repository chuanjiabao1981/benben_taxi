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
		render json: r
	end
end
