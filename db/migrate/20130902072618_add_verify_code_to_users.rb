class AddVerifyCodeToUsers < ActiveRecord::Migration
  def change
 	add_column :users,:verify_code,:string
  end
end
