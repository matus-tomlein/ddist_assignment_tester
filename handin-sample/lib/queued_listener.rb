module QueuedListener
  def listeners
    @listeners ||= []
  end

  def add_listener(listener)
    listeners << listener
  end

  def clear_listeners
    listeners.each do |listener|
      listener.remove_listener(self)
    end
    @listeners = []
  end

  def remove_listener(listener)
    listeners.delete listener
  end

  def process_event(event)
    if @test
      process_event_now event
    else
      start_processing_the_queue
      @event_queue << event
    end
  end

  def start_processing_the_queue
    return if @processing_thread

    @event_queue = Queue.new
    @processing_thread = Thread.new do
      loop do
        event = @event_queue.pop
        return if event.type == :exit
        process_event_now(event)
      end
    end
  end
end
