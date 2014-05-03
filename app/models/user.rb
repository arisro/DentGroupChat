class User < ActiveRecord::Base
	has_many :chat_ignores, class_name: "ChatIgnore", foreign_key: 'by_user_id'
 	has_many :chat_ignored, class_name: "ChatIgnore", foreign_key: 'on_user_id'

	def full_name
		"#{fname} #{lname}"
	end

	def get_profile_picture
		profile_picture || '0.png'
	end

	def chat_ignored_by?(user_id)
		!!chat_ignored.find_by(by_user_id: user_id)
	end
end