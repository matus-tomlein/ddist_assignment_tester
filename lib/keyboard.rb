java_import 'java.lang.System'
java_import 'java.awt.event.KeyEvent'

class Keyboard
  attr_reader :text_area

  def initialize(text_area)
    @text_area = text_area
  end

  def type_string(text, speed)
    text.split("").each do |char|
      type_char char
      sleep(speed) if speed
    end
  end

  def type_char(char)
    upper = char.upcase == char
    modifiers = upper ? KeyEvent::VK_SHIFT : 0

    EventHistory.log_event({ type: :typing,
                             char: char })

    text_area.dispatchEvent(KeyEvent.new(
      text_area,
      KeyEvent::KEY_TYPED, 0,
      modifiers, KeyEvent::VK_UNDEFINED, char[0].ord))

    text_area.dispatchEvent(KeyEvent.new(text_area,
                                         KeyEvent::KEY_PRESSED, 0,
                                         0, KeyEvent::VK_RIGHT))
    text_area.dispatchEvent(KeyEvent.new(text_area,
                                         KeyEvent::KEY_RELEASED, 0,
                                         0, KeyEvent::VK_RIGHT))
  end
end
