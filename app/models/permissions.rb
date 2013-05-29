module Permissions
  def self.permission_for(user)
    if user.nil?
      Rails.logger.debug("guest")
      GuestPermission.new(nil)
    elsif user.is_driver?
      Rails.logger.debug("driver")
      DriverPermission.new(user)
    elsif user.is_passenger?
      Rails.logger.debug("passenger")
      PassengerPermission.new(user)
    elsif user.is_zone_admin?
      Rails.logger.debug("zone_admin")
      ZoneAdminPermission.new(user)
    elsif user.is_super_admin?
      Rails.logger.debug("super_admin")
      SuperAdminPermission.new(user)
    else
      Rails.logger.debug("guest no")
      GuestPermission.new(nil)
    end
  end
end