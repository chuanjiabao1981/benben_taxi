class ZoneAdmin::TaxiCompaniesController < ApplicationController
	def index
		@taxi_companies = TaxiCompany.all
	end
	def new
		@taxi_company = TaxiCompany.new
	end
	def create
		@taxi_company = TaxiCompany.new(params[:taxi_company])
		if @taxi_company.save
			flash[:notice] = "成功创建 #{@taxi_company.name}!"
			return redirect_to url_for([:zone_admin,:taxi_companies])
		else
			render 'new'
		end
	end
	def destroy
		current_resource.destroy
		flash[:notice] = "成功删除 #{current_resource.name}!"
		return redirect_to url_for([:zone_admin,:taxi_companies])
	end

	private 
		def current_resource
			@current_resource ||= TaxiCompany.find(params[:id]) if params[:id]
		end
end
