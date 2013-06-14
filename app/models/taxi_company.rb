class TaxiCompany < ActiveRecord::Base
	validates_presence_of :name
	validates :name			  ,:length=>{:maximum => 100},presence: true,:uniqueness => { :scope => :tenant }
	validates :tenant         ,presence: true
	validates :boss 		  ,:length=>{:maximum => 60}
	belongs_to :tenant

	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }


end
