module Permissions
  class GuestPermission < BasePermission
    def initialize(user)
	  super(user)      
	  allow "api/v1/users"		, [:create_driver,:create_passenger]
	  allow "api/v1/sessions"	, [:driver_signin,:passenger_signin]
	  allow_param :user,[:mobile,:name,:password,:password_confirmation,:register_info,:plate,:tenant]
    end
  end
end