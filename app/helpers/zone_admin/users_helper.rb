module ZoneAdmin::UsersHelper
	def get_static_image_src(t,thumb=true)
		"http://api.map.baidu.com/staticimage?#{thumb ? "width=150&height=150&" : "width=640&height=480&"}center=#{(t.passenger_location.x + t.driver_location.x)/2.0},#{(t.passenger_location.y+t.driver_location.y)/2.0}&labels=#{t.passenger_location.x},#{t.passenger_location.y}|#{t.driver_location.x},#{t.driver_location.y}&labelStyles=司机,1,14,0xffffff,0xff0000,1|乘客,1,14,0xffffff,0x000fff,1"
	end
end
