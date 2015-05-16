import java.io.DataOutputStream;
import java.net.InetAddress;
import java.net.Proxy;
import java.io.IOException;
import java.net.UnknownHostException;
import java.io.OutputStream;
import java.io.InputStream;
import java.net.InetSocketAddress;

class ProxiedSocket extends java.net.Socket {

  public static NewSocketListener listener;

  public ProxiedSocket(String host, int port) throws UnknownHostException, IOException {
    super();

    if (ProxiedServerSocket.listener != null) {
      listener.socketCreated(host, port, port - 1);
      connect(new InetSocketAddress("localhost", port - 1));
    } else {
      connect(new InetSocketAddress(host, port));
    }
  }

}
