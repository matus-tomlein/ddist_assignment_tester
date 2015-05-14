$CLASSPATH << 'lib/java'
java_import 'java.awt.Component'
java_import 'CustomTextArea'

class TextArea < Component
  include CustomTextArea

  attr_reader :editor, :caret_position

  def init(editor)
    @editor = editor
    self
  end

  def keyTyped(ch)
    char = ch.chr

    relative_position = RelativePosition.generate_key
    event = Event.relative_write(editor.key,
                                 relative_position,
                                 nil,
                                 char)
    editor.process_event(event)
    editor.process_event(Event.move_caret_right(editor.key))
  end

  def deleteKeyPressed
    position = editor.relative_position_by_key(editor.caret_key).next
    raise 'No such position to delete' unless position
    editor.process_event Event.relative_delete(editor.key, position.key)
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
