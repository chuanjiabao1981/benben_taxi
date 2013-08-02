class ClientException < ActiveRecord::Base

	def self.build_user_client_excetion(params={},current_user)
		a 		= ClientException.new(params)
		a.role 	= current_user.nil? ? User::ROLE_GUEST : current_user.role
		a
	end
end
