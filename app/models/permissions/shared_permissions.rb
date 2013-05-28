module Permissions
	module SharedPermissions
		def all_allowed_permissions(user)
	      allow :main,[:overview]
	      allow :sessions, [:new, :create, :destroy]
		end
	end
end