class Tenant < ActiveRecord::Base
	validates :name,:length=>{:maximum => 100},:presence => true,:uniqueness => true

	
	def self.current_id=(id)
		Thread.current[:tenant_id] = id
	end
	def self.current_id
		Thread.current[:tenant_id]
	end

	def self.find_tenant(params)
		s  	= params[:tenant] 
		s ||= '阳泉'
		Tenant.find_by name: s
	end
end
