Automated testing of a Distributed Systems course assignment
============================================================

This projects tests hand-ins for the Distributed Systems course at Aarhus
University (spring 2015).
The main goal of the project is to help me (TA at the course) evaluate the
hand-ins.

# Installation

1. Install [JRuby](http://jruby.org)
2. `cd` into the project
3. Copy your solution to a folder called `handin`
4. `bundle install`
5. `ruby cli.rb` or `jruby cli.rb`

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

# Disclaimer

This project is my personal project, not part of the course.
