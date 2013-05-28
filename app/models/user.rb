#encoding: utf-8
class User < ActiveRecord::Base
	VALID_MOBILE_REGEX 	= /\A[\d]+\z/
	VALID_ACCOUNT_REGEX = /\A[a-zA-Z\d_]+\z/i

	ROLE_TYPE			= %w(super_admin zone_admin passenger driver)
	ROLE_SUPER_ADMIN    =  "super_admin"
	ROLE_ZONE_ADMIN		=  "zone_admin"
	ROLE_DRIVER 		=  "driver"
	ROLE_PASSENGER 		=  "passenger"

	STATUS_TYPE 		= %w(normal waiting_validate forbidden)

	USER_DEFAULT_STATUS =  {
							   "super_admin"=> "normal",
							   "zone_admin"=> "normal",
							   "passenger"=> "normal",
							   "driver"=> "normal"
						   }
	before_save :create_remember_token
	has_secure_password

	validates :mobile,  		:uniqueness => { :scope => :role }
	validates :account        ,:uniqueness => true,format:{with:VALID_ACCOUNT_REGEX},:unless => Proc.new {|u| u.is_driver? or u.is_passenger?}
	validates :mobile         ,:length => {:is => 11 },
								format: {with:VALID_MOBILE_REGEX} , 
								:unless => Proc.new {|u| u.is_super_admin? or u.is_zone_admin? } 
									
	validates :role           ,:inclusion => {  :in => ROLE_TYPE,:message   => "%{value} 不合法的用户类型!" }
	validates :status         ,:inclusion => { :in => STATUS_TYPE,:message => "%{value} 不合法的用户状态!"}
	validates :name			  ,:length=>{:maximum => 8}
	validates :tenant         ,presence: true, :unless => Proc.new {|u| u.is_super_admin?}

	belongs_to :tenant

	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	def self.build_a_user(params={},role)
		a 			= User.new(params)
		a.role 		= role
		a.status 	= USER_DEFAULT_STATUS[a.role]
		a.tenant    = Tenant.find_tenant params
		a
	end

	def self.build_driver(params={})
		User.build_a_user(params,ROLE_DRIVER)
	end
	def self.build_passenger(params={})
		User.build_a_user(params,ROLE_PASSENGER)
	end



	def is_passenger?
		self.role == ROLE_PASSENGER
	end
	def is_driver?
		self.role == ROLE_DRIVER
	end
	def is_super_admin?
		self.role == ROLE_SUPER_ADMIN
	end
	def is_zone_admin?
		self.role == ROLE_ZONE_ADMIN
	end
	private
		def create_remember_token
  			self.remember_token =  SecureRandom.urlsafe_base64
  		end

end
