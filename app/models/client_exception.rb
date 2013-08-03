require 'digest/md5'
class ClientException < ActiveRecord::Base

	def self.build_user_client_excetion(params={},current_user)
		a 		= ClientException.new(params)
		a.md5   = Digest::MD5.hexdigest(a.content + a.android_version.to_s + a.client_version.to_s + a. ios_version.to_s)
		tmp 	= ClientException.find_by(md5: a.md5)
		#Rails.logger.info(a.content + a.android_version.to_s + a.client_version.to_s + a. ios_version.to_s)
		if tmp.nil? 
			a
		else
			tmp.num = tmp.num + 1
			tmp
		end
	end
end
