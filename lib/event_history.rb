class EventHistory
  @@events = []

  def self.log_event(event)
    @@events << [ TimeKeeper.timestamp, event ]
  end

  def self.drop
    events = @@events
    @@events = []
    events
  end
end
