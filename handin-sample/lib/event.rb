require 'ostruct'

class Event
  def self.relative_write(editor, relative_position, previous_relative_position, text)
    new(type: :relative_write,
        editor: editor,
        relative_position: relative_position,
        previous_relative_position: previous_relative_position,
        text: text)
  end

  def self.relative_delete(editor, relative_position)
    new(type: :relative_delete,
        editor: editor,
        relative_position: relative_position)
  end

  def self.move_caret_right(editor)
    new(type: :move_caret_right,
        editor: editor,
        dont_publish: true)
  end

  def self.set_caret_position(editor, position)
    new(type: :set_caret_position,
        editor: editor,
        dont_publish: true,
        absolute_position: position)
  end

  def self.new(args)
    args[:time] = Time.now unless args[:time]
    OpenStruct.new(args)
  end
end
