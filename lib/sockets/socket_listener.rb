require_relative 'socket_proxy'

java_import 'NewSocketListener'

class SocketListener
  include NewSocketListener

  def serverSocketCreated(originalPort, newPort)
    SocketProxy.new('localhost', originalPort, newPort, :server).start
  end

  def socketCreated(host, originalPort, newPort)
    SocketProxy.new(host, newPort, originalPort, :client).start
  end
end
