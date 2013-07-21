class Advertisement < ActiveRecord::Base

	self.per_page = 30

	validates :content			  ,:length=>{:maximum => 250}

	validates_presence_of :start_time
	validates_presence_of :end_time
	validates_presence_of :content

	#default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }
end
