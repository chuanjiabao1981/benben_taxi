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
		taxi_request = current_resource
		if taxi_request.driver_response(params[:taxi_response],current_user)
			render json: taxi_request.get_json
		else
			render json: json_errors(taxi_request.errors)
		end
	end

	def cancel 
		taxi_request = current_resource
		if taxi_request.passenger_cancel(nil,current_user)
			render json: taxi_request.get_json
		else
			render json: json_errors(taxi_request.errors)
		end
	end

	def confirm
		taxi_request = current_resource
		if taxi_request.passenger_confirm(nil,current_user)
			render json: taxi_request.get_json
		else
			render json: json_errors(taxi_request.errors)
		end
	end

	def show
		render json:current_resource.get_json
	end

	private 
	def current_resource
		@current_resource ||= TaxiRequest.find(params[:id]) if params[:id]
	end

end
