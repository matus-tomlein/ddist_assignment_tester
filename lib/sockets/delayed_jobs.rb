class DelayedJobs

  DELAY = 0.1

  def initialize(sender)
    @sender = sender
    @tick_lock = Mutex.new
    @delayed_jobs = []
    process_delayed_jobs
  end

  def delay(job, time)
    @tick_lock.synchronize do
      (@delayed_jobs[time] ||= []) << job
    end
  end

  def process_delayed_jobs
    Thread.new do
      loop do
        jobs = @tick_lock.synchronize { @delayed_jobs.shift }

        jobs.each do |job|
          @sender.send(job)
        end if jobs

        sleep DELAY
      end
    end
  end
end
