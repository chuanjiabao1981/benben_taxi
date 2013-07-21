class ZoneAdmin::AdvertisementsController < ApplicationController
	def index
		@advertisements = Advertisement.all.paginate(:page => params[:page])
	end
	def new
		@advertisement = Advertisement.new
	end
end
