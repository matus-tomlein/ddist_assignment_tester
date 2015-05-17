package tester;

public class ProxiedServerSocket extends java.net.ServerSocket {

  public static NewSocketListener listener;
  private int originalPort;

  public ProxiedServerSocket(int port) throws java.io.IOException {
    super(port + TesterIdentifier.id - 1);

    int newPort = port + TesterIdentifier.id - 1;

    originalPort = port;
    if (originalPort == 0)
      originalPort = newPort - 1;

    if (ProxiedServerSocket.listener != null)
      ProxiedServerSocket.listener.serverSocketCreated(originalPort, newPort);
  }

  @Override
  public int getLocalPort() {
    return originalPort;
  }
}
