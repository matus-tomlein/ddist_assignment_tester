public class ProxiedServerSocket extends java.net.ServerSocket {

  public static NewSocketListener listener;

  public ProxiedServerSocket(int port) throws java.io.IOException {
    super(port + 1);
    System.out.println("ProxiedServerSocket 1");
    if (ProxiedServerSocket.listener != null) {
      ProxiedServerSocket.listener.serverSocketCreated(port, port + 1);
    }
  }
}
