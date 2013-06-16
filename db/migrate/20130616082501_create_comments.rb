class CreateComments < ActiveRecord::Migration
	def change
		create_table :comments do |t|
			t.integer    :author
			t.string 	 :author_role
			t.integer    :target
			t.string 	 :target_role
			t.text		 :content
			t.references :commentable, :polymorphic => true
			t.timestamps
		end
	end
end
