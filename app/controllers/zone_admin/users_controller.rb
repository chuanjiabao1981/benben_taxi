class ZoneAdmin::UsersController < ApplicationController
	include ZoneAdmin::UsersHelper
	def index
		params[:page] ||=1
		@users = User.where(:role => User::ROLE_DRIVER).paginate(:page => params[:page])
	end
	def new
		@user = User.build_driver
	end
	def create
		@user = User.build_driver(params[:user])
		if @user.save
			flash[:notice] = "成功创建司机 #{@user.name}!"
			return redirect_to url_for([:zone_admin,:users])
		else
			render 'new'
		end
	end
	def edit 
		@user = current_resource
	end
	def update
		@user = current_resource
		if @user.update(params[:user])
			flash[:notice] = "成功更新 #{@user.name} 信息!"
			return redirect_to url_for([:zone_admin,:users])
		else
			render 'edit'
		end
	end
	def destroy
		@user=current_resource
		@user.destroy
		flash[:notice] = "成功删除 #{@user.name}!"
		return redirect_to url_for([:zone_admin,:users])
	end
	def show
		@taxi_requests = TaxiRequest.where(driver_id: current_resource.id).order('created_at DESC').paginate(:page => params[:page])
		@taxi_requests_group = @taxi_requests.group_by {|t| t.created_at.beginning_of_day}
	end
	private 
		def current_resource
			@current_resource ||= User.find_by(id:params[:id],role: User::ROLE_DRIVER) if params[:id]
		end
end
