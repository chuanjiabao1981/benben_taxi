class SessionsController < ApplicationController
	before_action :already_signin , :only => [:new]
	def new
	end

	def create
		@user = User.find_by :account => params[:sessions][:account]
		if @user && @user.authenticate(params[:sessions][:password])
			sign_in(@user)
			return redirect_to root_path
		else
			flash.now[:error] = I18n.t('session.errors.account_or_password')
			render 'new'
		end
	end

	def destroy
		sign_out
		return redirect_to root_path
	end
	private 
		def already_signin
			return redirect_to root_path if current_user
		end
end
