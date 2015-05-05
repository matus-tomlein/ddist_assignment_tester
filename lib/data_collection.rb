require 'macaddr'

class DataCollection
  def self.init
    begin
      if File.exist? '.data_collection_id'
        data_collection_id(File.read('.data_collection_id'))
      else
        File.write '.data_collection_id', data_collection_id
      end
    rescue => ex
      puts "Failed creating ID for data collection #{ex.message}"
    end
  end

  def self.data_collection_id(id = generate_id)
    @data_collection_id ||= id
  end

  def self.generate_id
    (0...8).map { (65 + rand(26)).chr }.join
  end

  def self.start_test(testing_name)
    test_name = Commander.running_test
    send_dweet('start_test', {
      'test' => test_name,
      'testing' => testing_name,
    })
  end

  def self.end_test(testing_name, passed, error = '')
    if error.length > 1500
      error = error[0..1500]
    end

    test_name = Commander.running_test
    send_dweet('end_test', {
      'test' => test_name,
      'testing' => testing_name,
      'passed' => passed,
      'error' => error
    })
  end

  private

  def self.start_processing_the_queue
    return if @processing_thread

    @request_queue = Queue.new
    @processing_thread = Thread.new do
      loop do
        url = @request_queue.pop
        begin
          open(url).read
        rescue => ex
          puts "Failed collecting data #{ex.message}"
        end
      end
    end
  end

  def self.send_dweet(name, content)
    start_processing_the_queue

    content['id'] = data_collection_id
    content['mac'] = macaddr
    content['time'] = Time.now.to_s

    params = parameterize(content)
    @request_queue << "https://dweet.io/dweet/for/ddist2015-#{name}?#{params}"
  end

  def self.parameterize(params)
    URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
  end

  def self.macaddr
    @macaddr ||= Mac.addr
  end
end
