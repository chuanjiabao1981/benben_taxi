#encoding:utf-8
class MainController < ApplicationController
	before_action :not_signin

	def overview
		@drivers = User.all_drivers
		@infos   = [
						{
							color: 'infobox-green',
							icon:  'icon-comments',
							num:   User.drivers_num,
							content: '注册司机'
						},
						{
							color: 'infobox-blue',
							icon: 'icon-twitter',
							num:   User.passengers_num,
							content: '注册用户'
						},
						{
							color: 'infobox-pink',
							icon: 'icon-shopping-cart',
							num: TaxiRequest.today_success_requests,
							content: '今日成功打车次数'
						},
						{
							color: 'infobox-orange2',
							icon: 'icon-comments',
							num: DriverTrackPoint.get_latest_drivers_num,
							content: '在线司机数'
						}
				   ]
	end

	private
		def not_signin
			return redirect_to new_session_path unless current_user
		end
end
