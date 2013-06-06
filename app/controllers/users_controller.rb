class UsersController < ApplicationController
	def index
		@users = User.find_by :role => User::ROLE_ZONE_ADMIN
	end
	def new
		@user = User.new
	end
	def create
		@user = User.build_zone_admin(params[:user])
		if @user.save
			redirect_to users_path
		else
			Rails.logger.debug(@user.errors.full_messages)
			render 'new'
		end
	end
end
