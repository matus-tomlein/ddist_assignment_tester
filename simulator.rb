require_relative 'keyboard'

java_import 'javax.swing.event.MenuKeyEvent'
java_import 'java.awt.event.KeyEvent'

class Simulator
  attr_reader :editor, :keyboard

  def initialize(editor)
    @editor = editor
    @keyboard = Keyboard.new(text_area1)
    @exit_callback = nil
  end

  def listen(port)
    editor._getIPAddressField.setText('127.0.0.1')
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    trigger_listen_action
  end

  def connect(host, port)
    editor._getIPAddressField.setText(host.to_s)
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    trigger_connect_action
  end

  def disconnect
    trigger_disconnect_action
  end

  def write_in_text_area(text, caret, speed = 0.05)
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

  def current_port
    editor._getPortNumberField.getText.to_i
  end

  private

  def trigger_disconnect_action
    trigger_file_menu_action('Disconnect')
  end

  def trigger_connect_action
    trigger_file_menu_action('Connect')
  end

  def trigger_listen_action
    trigger_file_menu_action('Listen')
  end

  def trigger_file_menu_action(name)
    menu = editor.getJMenuBar.getMenu(0)
    menu.getItemCount.times do |i|
      item = menu.getItem(i)
      if item.getText.downcase.include?(name.downcase)
        item.doClick(200)
        return
      end
    end

    raise "Menu action #{name} not found"
  end

  def text_area1
    @area1 ||= editor._getArea1
  end
end
