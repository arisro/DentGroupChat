class User < ActiveRecord::Base
	def full_name
		"#{fname} #{lname}"
	end
end