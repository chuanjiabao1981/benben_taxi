module Permissions
  def self.permission_for(user)
    if user.nil?
      GuestPermission.new(nil)
    elsif user.is_driver?
      DriverPermission.new(user)
    elsif user.is_passenger?
      CustomerPermission.new(user)
    elsif user.is_zone_admin?
      ZoneAdminPermission.new(user)
    elsif user.is_super_admin?
      SuperAdminPermission.new(user)
    else
      GuestPermission.new(nil)
    end
  end
end