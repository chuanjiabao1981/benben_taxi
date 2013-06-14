class ZoneAdmin::UsersController < ApplicationController
	def index
		@users = User.all.where  :role => User::ROLE_DRIVER
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
			Rails.logger.debug(@user.errors.full_messages)
			render 'new'
		end
	end
end
