class Commander
  def test_multiple_clients(args)
    testing 'connecting the nodes' do
      listen [ 'node_0' ]
      connect [ 'node_1', 'node_0' ]
      connect [ 'node_2', 'node_0' ]
      connect [ 'node_3', 'node_0' ]
      wait 2
    end

    testing 'writing on the server' do
      text = 'aA' * 10
      write [ 0, 'node_0', text ]
      sleep 2

      4.times do |i|
        read_text = read_area1 [ "node_#{i}" ]
        raise "Wrong text: #{read_text} instead of #{text}" unless read_text.include? text
      end
    end

    testing 'writing on a client' do
      text = 'bB' * 10
      write [ 0, 'node_2', text ]
      sleep 2

      4.times do |i|
        read_text = read_area1 [ "node_#{i}" ]
        raise "Wrong text: #{read_text} instead of #{text}" unless read_text.include? text
      end
    end

    overview
  end
  alias_method :tmc, :test_multiple_clients

  def prepare_test_multiple_clients(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    4.times do |i|
      port = 5000 + i * 100
      add [ '127.0.0.1', port, "node_#{i}" ]
      Thread.new { start_tester port, handin_path }
    end
  end
  alias_method :ptmc, :prepare_test_multiple_clients
end
