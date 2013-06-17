class Comment < ActiveRecord::Base
	belongs_to :author,					:class_name=>"User",:foreign_key => "author_id"
	belongs_to :target,					:class_name=>"User",:foreign_key => "target_id"
	belongs_to :commentable,			:polymorphic => true



	validates_presence_of	:author_id
	validates_presence_of   :author_role
	validates_presence_of   :target_id
	validates_presence_of   :target_role
	validates_presence_of   :content
	validates_presence_of   :commentable_id
	validates_presence_of   :commentable_type
	validates :content			  ,:length=>{:maximum => 2000}
end
