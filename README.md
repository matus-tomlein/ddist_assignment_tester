Automated testing of a Distributed Systems course assignment
============================================================

This projects tests hand-ins for the Distributed Systems course at Aarhus
University (spring 2015).
The main goal of the project is to help me (TA at the course) evaluate the
hand-ins.

# Installation

1. `cd` into the project
2. Copy your solution to a folder called `handin`
3. `bin/jruby-1.7.19/bin/jruby cli.rb`

# Usage

Running `ruby cli.rb` will open a command-line interface that allows you to
connect to execute tests.
The easiest way to execute a test is for instance to run:

- `prepare_test1`
- Wait until 3 instances of the editor open
- `test1`

# Alternative usage

You can also start the instances of the editor manually:

`ruby tester.rb PORT PATH_TO_SOLUTION`

`PORT` and `PATH_TO_SOLUTION` are optional.
The default port is 4567 and the default path is `./handin`.

Afterwards, you can connect `ruby cli.rb` to the testers using:

`add NAME HOST PORT`

This will create a connection with the label NAME.
Then you can for instance use the following commands:

- `listen SERVER_NAME` – tell the tester to start listening
- `connect CLIENT_NAME SERVER_NAME`
- `disconnect CLIENT_NAME`
- `read CLIENT_NAME` - read the bottom text area
- `read_area1 CLIENT_NAME` - read the upper text area
- `write POSITION CLIENT_NAME MESSAGE` - write a message to the text area at the position
- `test1 SERVER1_NAME CLIENT_NAME SERVER2_NAME`

# Making your solution compatible with the tester

If you have you kept the basic structure from the example in Exercise 3, your
solution should work with the tester.

However, if you have diverged from the original example, add a class called
`Simulated` to the root of the solution.
It should provide the following methods (adapt to your implementation):

```
import editor.DistributedTextEditor;

public class Simulated {
  private DistributedTextEditor editor;

  // this will be called at the start of the test, initialize the JForm here
  public void init() {
    editor = new DistributedTextEditor();
  }

  // you can return the upper text area if you don't have a lower one
  public JTextArea getLowerTextArea() {
    return editor.getUpperTextArea();
  }

  public JTextArea getUpperTextArea() {
    return editor.getUpperTextArea();
  }

  public void startListening(int port) {
    // set the port somehow
    editor.getJMenuBar().getMenu(0).getItem(0).doClick(200);
  }

  public void connect(String ipAddress, int port) {
    // set the ip and port somehow
    editor.getJMenuBar().getMenu(0).getItem(1).doClick(200);
  }

  public void disconnect() {
    editor.getJMenuBar().getMenu(0).getItem(2).doClick(200);
  }
}
```

The tester will automatically find the `Simulated` class and use it to interact
with the solution.

# Contributing

Feel free to contribute new test cases or bug fixes using pull requests.

# Disclaimer

This is my personal project, not part of the course.
