require 'colored'

module TestHelper
  def testing(description = '')
    @failures = 0 unless @failures
    @testing_time = 0.0 unless @testing_time

    puts
    puts "Testing #{description}".bold
    begin
      t1 = Time.now
      yield
      delta = Time.now - t1

      @testing_time += delta
      puts "OK, #{delta/1000} s".green
    rescue => ex
      puts "Error: #{ex.message}".red
      @failures += 1
    end
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
end

module ConnectionHelper
  def initialize_connections
    @connections = {
      '0' => [ '127.0.0.1', '4567' ],
      '1' => [ '127.0.0.1', '4444' ],
      '2' => [ '127.0.0.1', '5555' ],
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

    begin
      res = JSON.parse(res)
      raise res['error'] if res['error']
    rescue JSON::ParserError => e
    end

    res
  end
end
