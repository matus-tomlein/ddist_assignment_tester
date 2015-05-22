require 'colored'

class SimultaneousTextCompareError < StandardError
  attr_reader :results

  def initialize(results)
    @results = results
  end
end

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
    `jruby tester.rb #{port} #{handin_path} > #{log_path} 2>&1`
  end

  def compare_texts(text_on_client, text_on_server, client_unit, client_repetitions, server_unit, server_repetitions, client_label = 'client', server_label = 'server')
    errors = []
    write_client = client_unit * client_repetitions
    write_server = server_unit * server_repetitions
    results = {
      :client_text_on_server => 100,
      :server_text_on_client => 100,
      :levenshtein_distance => 0
    }

    if text_on_client != text_on_server
      dst = StringDistance.calculate_distance(text_on_client, text_on_server)
      results[:levenshtein_distance] = dst
      errors << "Text on #{client_label} and #{server_label} are different: Levenshtein distance is #{dst} edits"
    end

    unless text_on_client.include? write_server
      percentage = calculate_percentage_of_included_repetitions(text_on_client, server_unit, server_repetitions)
      results[:server_text_on_client] = percentage
      errors << "Text on #{client_label} is garbled: contains #{percentage}% of #{server_unit}"
    end

    unless text_on_server.include? write_client
      percentage = calculate_percentage_of_included_repetitions(text_on_server, client_unit, client_repetitions)
      results[:client_text_on_server] = percentage
      errors << "Text on #{server_label} is garbled: contains #{percentage}% of #{client_unit}"
    end

    if errors.any?
      print "Text on #{client_label}: ".blue
      puts_output text_on_client, client_unit, server_unit
      print "Text on #{server_label}: ".blue
      puts_output text_on_server, client_unit, server_unit
      raise SimultaneousTextCompareError.new(results), errors.join("\n")
    end

    results
  end

  def puts_output(text, client_unit, server_unit)
    text.each_char do |c|
      if client_unit.include? c
        print c.blue.bold
      elsif server_unit.include? c
        print c.magenta.underline
      else
        print c
      end
    end
    puts
  end

  def calculate_percentage_of_included_repetitions(text, unit, repetitions)
    text.scan(unit).count.to_f / repetitions * 100
  end

  def clear_text_area(client, server)
    testing 'clearing the text area' do
      clear [ server ]
      wait 1
      clear [ client ]
      wait 1
      raise 'Failed to clear' unless read([ client ]).empty? && read([ server ]).empty?
    end
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
