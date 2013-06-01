class Api::V1::UsersController < Api::ApiController
	def create_driver
		user = User.build_driver(params[:user])
		create_user(user)
	end
	def create_passenger
		user = User.build_passenger(params[:user])
		create_user(user)
	end
	def nearby_driver
		render json: DriverTrackPoint.get_latest_drivers(params)
	end

	private
	def create_user(user)
		if user.save
			render json: login_success_json(user)
		else
			render json: json_errors(user.errors)
		end
	end
end
