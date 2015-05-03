class Commander
  def test_latency(args)
    server, client = (args.length == 2 ? args : [ '0', '1' ])

    connect_client_and_server client, server
    synchronize_time [ client, server ]

    testing 'measuring the latency writing on server' do
      write [ 0, server, 'X' * 100 ]
      wait 1

      server_history = event_history [ server ]
      client_history = event_history [ client ]
      latency = calculate_latency server_history, server_history, 'X'
      puts "Average server-server latency is: #{latency}".underline
      latency = calculate_latency server_history, client_history, 'X'
      puts "Average server-client latency is: #{latency}".underline
    end

    testing 'measuring the latency writing on client' do
      write [ 0, client, 'Y' * 100 ]
      wait 1

      client_history = event_history [ client ]
      server_history = event_history [ server ]
      latency = calculate_latency client_history, client_history, 'Y'
      puts "Average client-client latency is: #{latency}".underline
      latency = calculate_latency client_history, server_history, 'Y'
      puts "Average client-server latency is: #{latency}".underline
    end

    shutdown [ client ]
    shutdown [ server ]
  end
  alias_method :tl, :test_latency

  def calculate_latency(server_history, client_history, typed_char)
    typed_times = server_history.find_all do |item|
      item.last['type'] == 'typing' and item.last['char'] == typed_char
    end.map do |item|
      item.first
    end

    received_times = []
    last_received_char_count = 0
    client_history.find_all do |item|
      item.last['type'] == 'content_changed' and
        item.last['chars'][typed_char] and
        item.last['chars'][typed_char] > last_received_char_count
    end.each do |item|
      char_count = item.last['chars'][typed_char]
      (char_count - last_received_char_count).times do
        received_times << item.first
      end
      last_received_char_count = char_count
    end

    raise 'Client didn\'t receive all the events' unless typed_times.size == received_times.size

    latencies = [received_times, typed_times].transpose.map do |a|
      a.first - a.last
    end

    latencies.inject{ |sum, el| sum + el }.to_f / latencies.size
  end

  def prepare_test_latency(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :ptl, :prepare_test_latency
end
