class RegisterVerification < ActiveRecord::Base
	validates_presence_of	:mobile
	validates_presence_of	:code

	VERIFICATION_STATUS_INIT					=	"INIT"
	VERIFICATION_STATUS_DELIVERED_FAIL			=	"DELIVERED_FAIL"
	VERIFICATION_STATUS_DELIVERED_SUCCESS		=	"DELIVERED_SUCCESS"

	VERIFICATION_TIME_RANGE						=  2

	SMS_SEND_KEY								= "39fefe27f42ce49139287eb654fe5551"
	SMS_RESULT_FMT								= "json"
	SMS_PRODUCT_ID								= "1"
	SMS_HOST									= "tui3.com"
	SMS_PORT									= 80



	scope :not_time_out, lambda {
		where('created_at > ?',2.minutes.ago)
	}

	def self.generate_verification(params)
		s 			= RegisterVerification.new
		s.mobile 	= params[:mobile]
		s.code 	 	= rand(1000..9999)
		s.status 	= VERIFICATION_STATUS_INIT
		s
	end

	def self.deliver(id)
		s 					= RegisterVerification.find(id)
		res 				= sms_send(s.mobile,s.code)
		if res[:success]
			s.status 					= VERIFICATION_STATUS_DELIVERED_SUCCESS
		else
			s.status 					= VERIFICATION_STATUS_DELIVERED_FAIL
		end
		s.delivered_time			= Time.now
		s.sms_gate_ret_raw_msg 		= res[:sms_gate_ret_raw_msg]
		s.save 
	end

	def self.verify(mobile,code)
		RegisterVerification.not_time_out.where("mobile = ? and code = ?",mobile,code).size > 0
	end


	def self.sms_send(mobile,msg)
		url = "/api/send/?k=#{SMS_SEND_KEY}&r=#{SMS_RESULT_FMT}&p=#{SMS_PRODUCT_ID}&t=#{mobile}&c=#{build_msg(msg)}"
		request = Net::HTTP::Get.new(url)
		response = Net::HTTP.new(SMS_HOST, SMS_PORT).start {|http| http.request(request) }
		s 		 = response.body
		res 	 = JSON.parse(s)
		{
			success: res['err_code'] == 0,
			sms_gate_ret_raw_msg: s
		}
	end
	def self.build_msg(msg)
		"尊敬的用户,您的注册验证码是:#{msg},感谢您使用奔奔打车客户端!"
	end
end
