class Sender
  attr_accessor :active

  def initialize
    @ready_jobs = Queue.new
    @active = false
    process_ready_jobs
  end

  def send(job)
    @ready_jobs << job
  end

  def process_ready_jobs
    Thread.new do
      loop do
        begin
          job = @ready_jobs.pop
          job[:socket].send(job[:msg], 0) if active
        rescue => ex
          puts ex.message
        end
      end
    end
  end
end
