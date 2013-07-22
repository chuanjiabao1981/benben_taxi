class Advertisement < ActiveRecord::Base
	DEFAULT_JSON_RESULT 		= {
									:only =>[:content]
								  }
	self.per_page = 30

	validates :content			  ,:length=>{:maximum => 250}

	validates_presence_of :start_time
	validates_presence_of :end_time
	validates_presence_of :content


	scope :active, ->  { where("start_time < :now and end_time > :now",{now: Time.now}) }
	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	def self.active_items
		Advertisement.active
	end
end
