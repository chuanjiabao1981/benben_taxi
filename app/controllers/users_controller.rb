class UsersController < ApplicationController
	def index
		@users = User.where :role => User::ROLE_ZONE_ADMIN
	end
	def new
		@user = User.new
	end
	def create
		@user = User.build_zone_admin(params[:user])
		if @user.save
			redirect_to users_path
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
			flash[:notice] = "成功更新 #{@user.account} 信息!"
			return redirect_to url_for([:users])
		else
			render 'edit'
		end
	end
	def destroy
		@user=current_resource
		@user.destroy
		flash[:notice] = "成功删除 #{@user.name}!"
		return redirect_to url_for([:users])
	end
	private 
		def current_resource
			@current_resource ||= User.find_by(id:params[:id],role: User::ROLE_ZONE_ADMIN) if params[:id]
		end
end
