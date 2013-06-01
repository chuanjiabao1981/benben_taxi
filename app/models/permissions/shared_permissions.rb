module Permissions
	module SharedPermissions
		def all_allowed_permissions(user)
	      allow :main,[:overview]
	      allow :sessions, [:new, :create, :destroy]
		end

		def all_passenger_driver_allowed_permissions(user)
			if user && (user.is_driver? or user.is_passenger?)
				allow "api/v1/taxi_requests", [:show]
			end
		end
	end
end