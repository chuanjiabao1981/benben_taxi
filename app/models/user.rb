#encoding: utf-8
class User < ActiveRecord::Base

	self.per_page = 30

	VALID_MOBILE_REGEX 	= /\A[\d]+\z/
	VALID_ACCOUNT_REGEX = /\A[a-zA-Z\d_]+\z/i

	ROLE_TYPE			= %w(super_admin zone_admin passenger driver)
	ROLE_SUPER_ADMIN    =  "super_admin"
	ROLE_ZONE_ADMIN		=  "zone_admin"
	ROLE_DRIVER 		=  "driver"
	ROLE_PASSENGER 		=  "passenger"

	STATUS_TYPE 		= %w(normal waiting_validate forbidden)
	STATUS_TYPE_HUMAN   = {:normal => "帐号正常", :waiting_validate => "帐号审核", :forbidden => "帐号封禁"}
	STATUS_TYPE_CLASS   = {:waiting_validate => "label label-warning arrowed-in",
						   :normal => "label label-success arrowed",
						   :forbidden => "label label-important arrowed-in"
						  }

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
	validates :name			  ,:length=>{:maximum => 10}
	validates :tenant         ,presence: true, :unless => Proc.new {|u| u.is_super_admin?}
	validates :register_info  ,:length=>{:maximum => 256}
	validates :plate		  ,:length=>{:maximum => 20}

	belongs_to :tenant
	belongs_to :taxi_company


	default_scope { where(tenant_id: Tenant.current_id)  if Tenant.current_id }

	def self.driver_status_collections
		s = []
		STATUS_TYPE_HUMAN.each_pair {|key, value| s << [value,key] }
		s
	end
	def self.build_a_user(params={},role)
		a 			  = User.new(params)
		a.role 		  = role
		#如果有则用，没有则用默认值（权限控制保证正确性）
		a.status 	  ||= USER_DEFAULT_STATUS[a.role]

		if role == User::ROLE_DRIVER or role == User::ROLE_PASSENGER
			if Tenant.current_id
				a.tenant_id = Tenant.current_id
			else
				a.tenant = Tenant.find_tenant params
			end
		end
		a
	end
	def self.build_driver(params={})
		User.build_a_user(params,ROLE_DRIVER)
	end
	def self.build_passenger(params={})
		User.build_a_user(params,ROLE_PASSENGER)
	end
	def self.build_zone_admin(params={})
		User.build_a_user(params,ROLE_ZONE_ADMIN)
	end

	def self.drivers_num
		User.where(role: ROLE_DRIVER).count
	end

	def self.passengers_num
		User.where(role: ROLE_PASSENGER).count
	end

	def self.all_drivers
		User.where role: User::ROLE_DRIVER
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
	def status_is_normal?
		self.status.to_sym == :normal
	end
	def get_status_human
		User::STATUS_TYPE_HUMAN[self.status.to_sym]
	end
	private
		def create_remember_token
  			self.remember_token =  SecureRandom.urlsafe_base64
  		end

end
