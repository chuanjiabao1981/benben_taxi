class Api::V1::TaxiRequestsController < Api::ApiController
	def create
		return render json: json_params_null_errors if params[:taxi_request].nil?
		taxi_request = TaxiRequest.build_taxi_request(params[:taxi_request],current_user)
		if taxi_request.save
			# render json: json_add_data(:id,taxi_request.id)
			render json: taxi_request.as_json(TaxiRequest::DEFUALT_JSON_RESULT)
		else
			render json: json_errors(taxi_request.errors)
		end
	end
	def index
		if current_user.is_driver?
			taxi_requests = TaxiRequest.where(driver_id: current_user.id).order("created_at DESC").paginate(:page => params[:page])
		elsif current_user.is_passenger?
			taxi_requests = TaxiRequest.where(passenger_id: current_user.id).order("created_at DESC").paginate(:page => params[:page])
		end
		#render json: taxi_requests.as_json(only:[:id,:passenger_mobile,:driver_mobile,:driver_response_time,:created_at],:methods=>[:passenger_voice_url])
		render json: taxi_requests.as_json(TaxiRequest::DEFUALT_JSON_RESULT)
	end
	def latest 
		r = TaxiRequest.get_latest_taxi_requests
		return render json: r
	end

	def nearby
		r = TaxiRequest.get_nearby_taxi_requests(params)
		return render json: r
	end

	def answer
		return render json: json_params_null_errors if params[:taxi_response].nil?
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

	def show
		render json:current_resource.get_json
	end


	private 
	def current_resource
		@current_resource ||= TaxiRequest.find(params[:id]) if params[:id]
	end
end
