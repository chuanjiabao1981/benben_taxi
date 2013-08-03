class AddMd5ColToClientExceptions < ActiveRecord::Migration
  def change
  	add_column :client_exceptions,:md5,:string
  	add_column :client_exceptions,:num,:integer,:default => 1
  	add_index :client_exceptions,:md5

  	remove_column :client_exceptions, :role

  end
end
