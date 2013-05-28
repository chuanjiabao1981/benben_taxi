module Permissions
  class GuestPermission < BasePermission
    def initialize(user)
	  super(user)      
	  allow "api/v1/users", [:create_driver]
	  allow_param :user,[:mobile,:name,:password,:password_confirmation]
    end
  end
end