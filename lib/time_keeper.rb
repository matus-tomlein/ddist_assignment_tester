class TimeKeeper
  @@initial_checkpoint = Time.now.to_i

  def self.start_new_checkpoint
    @@initial_checkpoint = Time.now.to_i
    @@initial_checkpoint
  end

  def self.set_checkpoint(checkpoint)
    @@initial_checkpoint = checkpoint
  end

  def self.timestamp
    Time.now.to_i - @@initial_checkpoint
  end
end
