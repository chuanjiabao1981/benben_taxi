namespace :benben_taxi do
	task :init_super_admin => :environment do
		a = User.new
		a.account 					= 'super_admin'
		a.password					= '8'
		a.password_confirmation 	= '8'
		a.role 						= User::ROLE_SUPER_ADMIN
		a.status 					= User::USER_DEFAULT_STATUS[a.role]
		a.save!
	end
end
