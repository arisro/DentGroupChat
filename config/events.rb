WebsocketRails::EventMap.describe do
  subscribe :chat_new_message, to: ChatController, with_method: :new_message
  subscribe :chat_new_user, to: ChatController, with_method: :new_user
  subscribe :client_connected, to: ChatController, with_method: :client_connected
  subscribe :client_disconnected, to: ChatController, with_method: :client_disconnected
  namespace :websocket_rails do
  	subscribe :subscribe_private, to: ChatController, with_method: :authorize_channel
  end
end
