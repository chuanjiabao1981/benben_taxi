class Api::V1::ClientExceptionsController < Api::ApiController
	def create
		client_exception = ClientException.build_user_client_excetion(params[:client_exception],current_user)
		if client_exception.save
			Rails.logger.info("save exception sucess!")
			render json: json_response_ok
		else
			#TODO ::erro output
			Rails.logger.info("save exception fail!")
			render json: json_errors(client_exception.errors)
		end
	end
end
