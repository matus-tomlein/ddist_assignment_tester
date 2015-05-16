class ProxiedSocketManager
  def self.start_proxy
    require_relative 'socket_listener'
    java_import 'ProxiedServerSocket'
    java_import 'ProxiedSocket'
    listener = SocketListener.new
    ProxiedServerSocket::listener = listener
    ProxiedSocket::listener = listener
  end
end
