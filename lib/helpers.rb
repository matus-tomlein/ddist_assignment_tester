require 'colored'

module TestHelper
  def testing(description = '')
    @failures = 0 unless @failures
    @testing_time = 0.0 unless @testing_time

    puts
    puts "Testing #{description}".bold
    begin
      DataCollection.start_test(description)

      t1 = Time.now
      yield
      delta = Time.now - t1

      @testing_time += delta
      puts "OK, #{delta/1000} s".green

      DataCollection.end_test(description, true)
    rescue => ex
      puts "Error: #{ex.message}".red

      DataCollection.end_test(description, false, ex.message)
      @failures += 1
      return false
    end
    true
  end

  def wait(seconds)
    puts "Waiting for #{seconds} seconds".blue
    sleep seconds
  end

  def overview
    puts
    puts "SUMMARY".blue
    puts "Failures: #{@failures}".bold.underline
    puts "Time: #{@testing_time / 1000} s".bold.underline
    @failures = 0
    @testing_time = 0.0
  end

  def test_writing_message(reader, writer, length = 50)
    new_text = generate_string length
    previous_text = read_area1 [writer]
    caret = previous_text == '' ? 0 : rand(previous_text.size)
    expected_text = previous_text.insert caret, new_text

    write([caret, writer, new_text])
    wait 1
    text = read [reader]

    if text != expected_text
      raise "Expected '#{expected_text}' but got '#{text}''"
    end

    true
  end

  def connect_client_and_server(client, server)
    t_listen = Thread.new do
      testing 'starting listening on server' do
        listen_and_update_port server
      end
    end
    wait 3

    t_connect = Thread.new do
      testing 'connecting client to server' do
        connect [client, server]
      end
    end
    wait 1

    t_listen.join
    t_connect.join
  end

  def generate_string(length)
    (0...length).map { (65 + rand(26)).chr }.join
  end

  def start_tester(port, handin_path)
    log_path = "log/node_#{port}.log"
    print "Output from node with port #{port} will be saved to file #{log_path}.\n".blue
    `bin/jruby-1.7.19/bin/jruby tester.rb #{port} #{handin_path} > #{log_path} 2>&1`
  end
end

module ConnectionHelper
  def initialize_connections
    @connections = {
      '0' => [ '127.0.0.1', '4567', '4577' ],
      '1' => [ '127.0.0.1', '4444', '4454' ],
      '2' => [ '127.0.0.1', '5555', '5565' ],
    }
    @server = '0'
  end

  def connection_host_and_port(connection)
    unless connections.has_key? connection
      raise "No such connection #{connection}"
    end
    connections[connection]
  end

  def to_get_params(args)
    return '' unless args.any?
    args_arr = []
    args.each do |key, value|
      args_arr << "#{key}=#{CGI::escape(value.to_s)}"
    end
    return '?' + args_arr.join('&')
  end

  # Execute a GET request to the connection
  def get(connection, path, args = {})
    host, port = connection_host_and_port(connection)

    res = open(
      "http://#{host}:#{port}#{path}#{to_get_params(args)}"
    ).read
    puts res if @debug

    begin
      res = JSON.parse(res)
      raise res['error'] if res.is_a?(Hash) and res['error']
      return res
    rescue JSON::ParserError => e
    end

    res
  end
end
