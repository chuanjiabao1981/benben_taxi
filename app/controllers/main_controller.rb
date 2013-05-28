class MainController < ApplicationController
	before_action :not_signin

	def overview
	end

	private
		def not_signin
			return redirect_to new_session_path unless current_user
		end
end
