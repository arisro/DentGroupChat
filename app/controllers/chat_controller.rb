class ChatController < WebsocketRails::BaseController
	include ActionView::Helpers::SanitizeHelper

	def initialize_session
		puts "Chat session Initialized\n"
	end

	def system_msg(ev, msg)
		broadcast_message ev, { 
			user_name: 'system', 
			received: Time.now.to_s(:short), 
			msg_body: msg
		}
	end

	def user_msg(ev, msg)
		# broadcast_message ev, { 
		# 	user_name:  connection_store[:user][:user_name], 
		# 	received:   Time.now.to_s(:short), 
		# 	msg_body:   ERB::Util.html_escape(msg) 
		# }
	end

	def client_connected
		# system_msg :new_message, "client #{client_id} connected"
	end

	def client_disconnected
		user = User.find(connection_store[:user][:user_id])
		user.update(is_online: false)
		connection_store[:user] = nil
		# system_msg "client #{client_id} disconnected"
		# broadcast_user_list
	end


	def new_user
		user = User.find(message[:user_id])
		hash = Digest::MD5.hexdigest("#{user.id}saltgoeshere")
		if hash == message[:key]
			user.update(is_online: true)
			connection_store[:user] = { user_id: user.id, user_name: user.full_name, profile_picture: user.get_profile_picture, specialization: user.specialization, key: hash }
			WebsocketRails["u#{user.id}".to_s].make_private
			# broadcast_user_list
		end
	end

	def broadcast_user_list
		users = connection_store.collect_all(:user)
		broadcast_message :chat_user_list, users
	end

	def new_message
		unless connection_store[:user].nil?
			# check if user is ignored
			# this is invalidated on the website
			are_ignored = Rails.cache.fetch("chat/are_ignored/#{message[:to_user_id]}/#{connection_store[:user][:user_id]}", expires_in: 12.hours) do
				ChatIgnore.uncached do
					ChatIgnore.where('(by_user_id = ? and on_user_id = ?) or (by_user_id = ? and on_user_id = ?)', message[:to_user_id], connection_store[:user][:user_id], connection_store[:user][:user_id], message[:to_user_id]).count
				end
			end
			if are_ignored == 0
				ChatMessage.create(from_user_id: connection_store[:user][:user_id], to_user_id: message[:to_user_id], body: message[:msg_body])
				WebsocketRails["u#{message[:to_user_id]}"].trigger 'chat_new_message', {
					from: connection_store[:user],
					message: message[:msg_body]
				}
			end
		end
	end

	def authorize_channel
		system_msg :authorizesubscribe, "authorize subscribe"
		if connection_store[:user].nil?
			deny_channel({:message => 'authorization failed!'})
		else
			accept_channel connection_store[:user]
		end
	end
end