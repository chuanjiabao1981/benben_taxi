module Permissions
  class GuestPermission < BasePermission
    def initialize(user)
	  super(user)      
	  allow "api/v1/users"		, [:create_driver,:create_passenger]
	  allow "api/v1/sessions"	, [:driver_signin,:passenger_signin]
	  allow_param :user,[:mobile,:name,:password,:password_confirmation,:register_info,:plate,:tenant_name,:verify_code]
	  
	  allow "api/v1/client_exceptions",[:create]
	  allow_param :client_exception,[:content,:android_version,:ios_version,:client_version]

	  allow "api/v1/register_verifications",[:create]
	  allow_param :register_verification,[:mobile]
    end
  end
end