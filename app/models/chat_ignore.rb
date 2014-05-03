class ChatIgnore < ActiveRecord::Base
	belongs_to :author, class_name: "User", foreign_key: "by_user_id"
	belongs_to :user, class_name: "User", foreign_key: "on_user_id"

	validates_uniqueness_of :by_user_id, :scope => :on_user_id

	scope :lookup, -> (by_user_id, on_user_id) { where("by_user_id = ? and on_user_id = ?", by_user_id, on_user_id) }
end