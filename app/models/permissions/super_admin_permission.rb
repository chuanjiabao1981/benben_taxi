module Permissions
  class SuperAdminPermission < BasePermission
    def initialize(user)
      allow_all
    end
  end
end