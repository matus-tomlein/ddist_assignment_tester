class Editor
  include QueuedListener

  attr_reader :key, :caret_key

  def initialize
    @key = (0...4).map { (65 + rand(26)).chr }.join
    @first_position = RelativePosition.new('0')
    @positions = { @first_position.key => @first_position }
    @caret_key = @first_position.key
  end

  def content
    contents = []
    position = @first_position.next

    while position
      contents << position.content
      position = position.next
    end

    contents.join ''
  end

  def initialize_listener(listener)
    previous_position = @first_position

    while previous_position.next
      position = previous_position.next

      event = Event.relative_write(
        key,
        position.key,
        previous_position.key,
        position.content
      )
      listener.process_event(event)

      previous_position = position
    end
  end

  def relative_position_for_caret(caret)
    @first_position.find(caret).key
  end

  def relative_position_by_key(relative_position_key)
    position = @positions[relative_position_key]

    if position and position.replaced_by
      relative_position_by_key(position.replaced_by)
    else
      position
    end
  end

  private

  def process_event_now(event)
    send event.type, event
    publish_event(event) unless event.dont_publish
  end

  def relative_write(event)
    return if @positions[event.relative_position]

    if event.previous_relative_position.nil?
      event.previous_relative_position = @caret_key
    end
    previous = relative_position_by_key(event.previous_relative_position)

    unless previous
      raise "Previous position not found for #{event.text}"
    else
      position = RelativePosition.new(event.relative_position)
      @positions[position.key] = position
      position.content = event.text

      position.previous = previous
      position.next = previous.next
      position.next.previous = position if position.next
      previous.next = position
    end
  end

  def move_caret_right(event)
    caret = relative_position_by_key(@caret_key)
    @caret_key = caret.next.key if caret.next
  end

  def set_caret_position(event)
    @caret_key = @first_position.find(event.absolute_position).key
  end

  def relative_delete(event)
    if event.relative_position.nil?
      event.relative_position = @caret_key
    end

    relative_position = relative_position_by_key(event.relative_position)
    return if relative_position.previous.nil?

    relative_position.previous.next = relative_position.next
    relative_position.next.previous = relative_position.previous if relative_position.next

    relative_position.replaced_by = relative_position.next
    relative_position.previous = nil
    relative_position.next = nil
  end

  def publish_event(event)
    t = Thread.new do
      listeners.each do |listener|
        next if listener.key == event.editor

        new_event = event.dup
        new_event.editor = key
        listener.process_event(new_event)
      end
    end if listeners.any?

    t.join if t and @test
  end
end
