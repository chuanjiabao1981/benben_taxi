class ZoneAdmin::AdvertisementsController < ApplicationController
	def index
		params[:page]	= 1
		@advertisements = Advertisement.order(:created_at).paginate(:page => params[:page])
	end
	def new
		@advertisement = Advertisement.new
	end
	def create
		@advertisement = Advertisement.new(params[:advertisement])
		if @advertisement.save
			flash[:notice] = "成功发布广告!"
			return redirect_to url_for([:zone_admin,:advertisements])
		else
			render 'new'
		end
	end
	def edit
		@advertisement = current_resource
	end
	def update
		@advertisement = current_resource
		if @advertisement.update(params[:advertisement])
			flash[:notice] = "成功更新广告!"
			return redirect_to url_for([:zone_admin,:advertisements])
		else
			render 'edit'
		end
	end
	def destroy
		current_resource.destroy
		flash[:notice] = "成功删除广告!"
		return redirect_to url_for([:zone_admin,:advertisements])
	end
	private 
		def current_resource
			@current_resource ||= Advertisement.find(params[:id]) if params[:id]
		end
end
