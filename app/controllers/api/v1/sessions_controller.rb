class Api::V1::SessionsController < Api::ApiController
	def driver_signin
		user_signin(params,User::ROLE_DRIVER)
		
	end
	def passenger_signin
		user_signin(params,User::ROLE_PASSENGER)

	end

	private 
	def user_signin(params,role)
		p     = params[:session]
		p   ||= {}
		user = User.find_by mobile: p[:mobile], role: role
		if user && user.authenticate(params[:session][:password])
			if user.status_is_normal?
				return render json:login_success_json(user)
			else
				return render json:json_base_errors(user.get_status_human)
			end
		else
			return render json:json_base_errors(I18n.t('session.errors.account_or_password'))
		end

	end
end
