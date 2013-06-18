class Api::V1::CommentsController < Api::ApiController
	def index
		return render json: current_resource.as_json(TaxiRequest::DEFAULT_JSON_RESULT_WITH_COMMENTS)
	end
	def create 
		taxi_request = current_resource
		if current_user.is_driver?
			if taxi_request.comment_on_passenger(params[:taxi_request],current_user)
				render json: taxi_request.get_json
			else
				render json: json_errors(taxi_request.errors)
			end
		elsif current_user.is_passenger?
			if taxi_request.comment_on_driver(params[:taxi_request],current_user)
				render json: taxi_request.get_json
			else
				render json: json_errors(taxi_request.errors)
			end
		else
			# 错误 是否是在状态为success 
			render json:json_base_errors(I18n.t('views.text.unauthorized'))
		end		
	end


	private 
	def current_resource
		if params[:taxi_request_id]
			return @current_resource ||= TaxiRequest.find(params[:taxi_request_id]) 
		elsif params[:id]
			return @current_resource ||= Comment.find(params[:id])
		end
	end
end
