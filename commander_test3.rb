class Commander
  def test3(args)
    server, client, second_client = if args.length == 3
                                      args
                                    else
                                      ['0', '1', '2']
                                    end

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

    testing 'exit the first client' do
      shutdown [client]
    end
    wait 1

    testing 'connecting second client to server' do
      connect [second_client, server]
    end
    wait 1

    testing 'writing a message on second client' do
      test_writing_message second_client, server, 50
    end

    testing 'writing a message on server' do
      test_writing_message server, second_client, 50
    end

    overview
  end
  alias_method :t3, :test3

  def prepare_test3(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    @instance_threads = []
    @instance_threads << Thread.new { start_tester 4567, handin_path }
    @instance_threads << Thread.new { start_tester 4444, handin_path }
    @instance_threads << Thread.new { start_tester 5555, handin_path }
  end
  alias_method :pt3, :prepare_test3

  def kill_test3(args)
    @instance_threads.each do |thread|
      thread.kill
    end
  end
end
