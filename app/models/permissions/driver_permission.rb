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
    end
  end
end