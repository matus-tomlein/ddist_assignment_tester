require_relative 'keyboard'

class Simulator
  attr_reader :editor, :keyboard

  def initialize(editor)
    @editor = editor
    @keyboard = Keyboard.new(text_area1)
    @exit_callback = nil
  end

  def listen(port)
    editor._getIPAddressField.setText('localhost')
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    editor._getListenAction.actionPerformed(nil)
  end

  def connect(host, port)
    editor._getIPAddressField.setText(host.to_s)
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    editor._getConnectAction.actionPerformed(nil)
  end

  def disconnect
    editor._getDisconnectAction.actionPerformed(nil)
  end

  def write_in_text_area(text, caret, speed = 15)
    text_area1.requestFocus
    text_area1.setCaretPosition(caret.to_i)

    keyboard.type_string(text, speed)
  end

  def read_text_area
    text_area1.getText
  end

  def read_bottom_text_area
    editor._getArea2.getText
  end

  def clear_text_area
    text_area1.setText ''
  end

  private

  def text_area1
    @area1 ||= editor._getArea1
  end
end
