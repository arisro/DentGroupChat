class User < ActiveRecord::Base
	def full_name
		"#{fname} #{lname}"
	end

	def get_profile_picture
		profile_picture || '0.png'
	end
end