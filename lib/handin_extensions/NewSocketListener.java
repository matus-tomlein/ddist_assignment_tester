package tester;

public interface NewSocketListener {
  public void serverSocketCreated(int originalPort, int newPort);
  public void socketCreated(String host, int originalPort, int newPort);
}
