require 'java'

class Simulator
  def initialize(folder_name)
    @folder_name = folder_name
  end

  def run
    editor._getListenAction.actionPerformed(nil)
    area1 = editor._getArea1
    area1.requestFocus
    area1.setCaretPosition(100)

    java_import 'java.awt.Robot'
    java_import 'java.awt.event.KeyEvent'
    robot = Robot.new

    robot.keyPress(KeyEvent::VK_SHIFT)
    robot.keyPress(KeyEvent::VK_A)
    robot.keyRelease(KeyEvent::VK_A)
    robot.keyRelease(KeyEvent::VK_SHIFT)
  end

  def editor
    @editor ||= create_editor
  end

  private

  def create_editor
    $CLASSPATH << @folder_name
    java_import 'DistributedTextEditor'
    DistributedTextEditor.new
  end
end
