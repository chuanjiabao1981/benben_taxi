class Api::V1::UsersController < Api::ApiController
	def create_driver
		user = User.build_driver(params[:user])
		if user.save
			render json: login_success_json(user)
		else
			render json: user.errors
		end
	end
end
