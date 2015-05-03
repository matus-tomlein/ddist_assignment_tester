java_import 'java.awt.Component'

class TextArea < Component
  attr_reader :editor, :caret_position

  def init(editor)
    @editor = editor
    self
  end

  def dispatchEvent(key_event)
    if key_event.getID == KeyEvent::KEY_TYPED
      char = key_event.getKeyChar.chr

      relative_position = RelativePosition.generate_key
      event = Event.relative_write(editor.key,
                                   relative_position,
                                   nil,
                                   char)
      editor.process_event(event)
    elsif key_event.getID == KeyEvent::KEY_RELEASED and
      key_event.getKeyCode == KeyEvent::VK_RIGHT
      editor.process_event(Event.move_caret_right(editor.key))
    end
  end

  def getText
    @editor.content
  end

  def setCaretPosition(position)
    editor.process_event(Event.set_caret_position(editor.key, position))
  end

  def getCaretPosition
    caret = editor.relative_position_by_key(editor.caret_key)
    caret.absolute_position
  end

  def requestFocus; end;
  def setText(text); raise 'Not implemented'; end
end
