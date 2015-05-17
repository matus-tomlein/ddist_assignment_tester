class ShuffledJobs
  attr_reader :window

  def initialize(sender)
    @sender = sender
    @shuffled_jobs = []
    @lock = Mutex.new
    @window = 0
  end

  def shuffle(job)
    @lock.synchronize { @shuffled_jobs << job }
  end

  def set_window(window)
    previous_window = @window
    @window = window

    process_shuffled_jobs if @window > 0 and previous_window == 0
  end

  def process_shuffled_jobs
    Thread.new do
      loop do
        jobs = @lock.synchronize do
          jobs = @shuffled_jobs
          @shuffled_jobs = []
          jobs
        end

        puts "Shuffling #{jobs.size} jobs"
        jobs.shuffle.each { |job| @sender.send job }

        return if @window == 0
        sleep @window
      end
    end
  end
end
