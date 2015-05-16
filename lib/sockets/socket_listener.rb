require_relative 'socket_proxy'

java_import 'tester.NewSocketListener'

class SocketListener
  include NewSocketListener

  def serverSocketCreated(originalPort, newPort)
    SocketProxy.create_and_start('localhost', originalPort, newPort, :server)
  end

  def socketCreated(host, originalPort, newPort)
    SocketProxy.create_and_start(host, newPort, originalPort, :client)
  end
end
