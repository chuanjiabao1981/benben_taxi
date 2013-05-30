module Permissions
  class DriverPermission < BasePermission
    def initialize(user)
      #allow :users, [:new, :create, :edit, :update]
      #allow :sessions, [:new, :create, :destroy]
      #allow :topics, [:index, :show, :new, :create]
      #allow :topics, [:edit, :update] do |topic|
      #  topic.user_id == user.id
      #end
      #allow_param :topic, :name
      super(user)
      allow "api/v1/driver_track_points"    , [:create]
      allow_param :driver_track_point,[:mobile,:lng,:lat,:radius,:coortype]

    end
  end
end