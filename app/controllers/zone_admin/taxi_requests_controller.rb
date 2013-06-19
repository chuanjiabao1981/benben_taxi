class ZoneAdmin::TaxiRequestsController < ApplicationController
	def show
		@taxi_request = current_resource
	end
	private 
		def current_resource
			@current_resource ||= TaxiRequest.find(params[:id]) if params[:id]
		end
end
