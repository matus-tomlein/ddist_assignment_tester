require_relative 'keyboard'

java_import 'javax.swing.event.MenuKeyEvent'
java_import 'java.awt.event.KeyEvent'

class Simulator
  attr_reader :editor_access, :keyboard

  def initialize(editor_access)
    @editor_access = editor_access
    @keyboard = Keyboard.new(upper_text_area)
    @exit_callback = nil
  end

  def listen(port)
    editor_access.start_listening(port)
  end

  def connect(host, port)
    editor_access.connect(host, port)
  end

  def disconnect
    editor_access.disconnect
  end

  def set_caret_position(caret)
    upper_text_area.setCaretPosition(caret.to_i)
  end

  def write_in_text_area(text, caret, speed = 0.03)
    upper_text_area.requestFocus
    set_caret_position(caret) if caret && caret.to_i >= 0

    keyboard.type_string(text, speed)
  end

  def read_text_area
    upper_text_area.getText
  end

  def read_bottom_text_area
    lower_text_area.getText
  end

  def clear_text_area
    upper_text_area.setText ''
  end

  def current_port
    editor_access.current_port
  end

  private

  def upper_text_area
    editor_access.upper_text_area
  end

  def lower_text_area
    editor_access.lower_text_area
  end
end
