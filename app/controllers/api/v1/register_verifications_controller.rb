class Api::V1::RegisterVerificationsController < Api::ApiController
	def create
		register_verification = RegisterVerification.generate_verification(params[:register_verification])
		if register_verification.save
			RegisterVerification.delay.deliver(register_verification.id)
			render json: json_response_ok
		else
			render json: json_errors(register_verification.errors)
		end
	end
end
