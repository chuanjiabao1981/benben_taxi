class Api::V1::DriverTrackPointsController <  Api::ApiController
	def create
		return render json: json_response_ok if params[:coortype] == 'unknown'
		driver_track_point = DriverTrackPoint.build_driver_track_point(params[:driver_track_point],current_user)
		if driver_track_point.save
			render json: json_response_ok
		else
			render json: json_errors(driver_track_point.errors)
		end
	end
	def index
		return render json: DriverTrackPoint.get_drivers_latest_track_point(params)
	end
end
