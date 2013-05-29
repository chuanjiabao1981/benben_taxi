module Api::V1::SessionsHelper
	def login_success_json(user)
		json_add_data(:token_key,"remember_token")
		json_add_data(:token_value,user.remember_token)
	end
end
