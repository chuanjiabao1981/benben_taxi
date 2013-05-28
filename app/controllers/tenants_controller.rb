class TenantsController < ApplicationController
	def index
		@tenants = Tenant.all
	end
	def new
		@tenant = Tenant.new
	end
	def edit
		@tenant = current_resource
	end
	def create
		@tenant = Tenant.new(params[:tenant])
		if @tenant.save
			return redirect_to tenants_path
		else
			render 'new'
		end
	end

	def update
		@tenant = current_resource
		if @tenant.update(params[:tenant])
			return redirect_to tenants_path
		else
			render 'new'
		end
	end

	def destroy
		@tenant = current_resource
		@tenant.destroy if @tenant
		return redirect_to tenants_path
	end

	private 
		def current_resource
			@current_resource = Tenant.find(params[:id]) if params[:id]
		end
end
