class ZoneAdmin::UsersController < ApplicationController
	def index
		@users = User.find_by  :role => User::ROLE_DRIVER
	end
end
