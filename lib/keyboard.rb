java_import 'KeyboardImpl'
java_import 'KeyboardListener'

class Keyboard
  attr_reader :java_keyboard

  def initialize(text_area)
    @java_keyboard = KeyboardImpl.new(text_area, KeyboardListenerImpl.new)
  end

  def press_delete(num_times = 1)
    num_times.times do
      java_keyboard.pressDelete();
      sleep 0.025
    end
  end

  def press_backspace(num_times = 1)
    num_times.times do
      java_keyboard.pressBackspace();
      sleep 0.025
    end
  end

  def type_string(text, speed)
    java_keyboard.typeString(text, (speed * 1000).to_i)
  end
end

class KeyboardListenerImpl
  include KeyboardListener

  def logKeyPress(ch)
    EventHistory.log_event({ type: :typing, char: ch.to_s })
  end
end
