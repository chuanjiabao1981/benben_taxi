class Api::V1::AdvertisementsController < Api::ApiController
	def index
		advertisements 		=	Advertisement.active_items
		render json: advertisements.as_json(Advertisement::DEFAULT_JSON_RESULT)
	end
end
