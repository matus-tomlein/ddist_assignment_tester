package tester;

import java.io.DataOutputStream;
import java.net.InetAddress;
import java.net.Proxy;
import java.io.IOException;
import java.net.UnknownHostException;
import java.io.OutputStream;
import java.io.InputStream;
import java.net.SocketAddress;
import java.net.InetSocketAddress;

public class ProxiedSocket extends java.net.Socket {

  public static NewSocketListener listener;
  public static int i = 1;

  public ProxiedSocket() {
    super();
  }

  public ProxiedSocket(String host, int port) throws UnknownHostException, IOException {
    super();

    connect(new InetSocketAddress(host, port));
  }

  public ProxiedSocket(InetAddress address, int port) throws IOException {
    super();

    connect(new InetSocketAddress(address.getHostAddress(), port));
  }

  @Override
  public void connect(SocketAddress endpoint) throws IOException {
    super.connect(translateSocketAddress(endpoint));
  }

  private SocketAddress translateSocketAddress(SocketAddress endpoint) {
    int port = ((InetSocketAddress) endpoint).getPort();
    String hostname = ((InetSocketAddress) endpoint).getHostName();

    int newPort = port + TesterIdentifier.id + ProxiedSocket.i;
    ProxiedSocket.i++;

    if (ProxiedServerSocket.listener != null) {
      listener.socketCreated(hostname, port, newPort);
      return new InetSocketAddress("127.0.0.1", newPort);
    }
    return new InetSocketAddress(hostname, port);
  }

}
