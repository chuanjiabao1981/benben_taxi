module Permissions
  class PassengerPermission < BasePermission
    def initialize(user)
      super(user)
      allow "api/v1/taxi_requests"    , [:create]
      allow_param :taxi_request,[:passenger_mobile,:passenger_lat,:passenger_lng,:waiting_time_range]

    end
  end
end