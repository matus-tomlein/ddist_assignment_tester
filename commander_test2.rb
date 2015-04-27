class Commander
  def test2(args)
    server, client, second_server = if args.length == 3
                                      args
                                    else
                                      ['0', '1']
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

    t_client = Thread.new do
      testing 'writing a message on client' do
        test_writing_message client, server, 500
      end

      testing 'updating the message on client' do
        test_writing_message client, server, 500
      end
    end

    t_server = Thread.new do
      testing 'writing a message on server' do
        test_writing_message server, client, 500
      end

      testing 'updating the message on server' do
        test_writing_message server, client, 500
      end
    end

    t_client.join
    t_server.join

    overview
  end
  alias_method :t2, :test2

  def prepare_test2(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    @instance_threads = []
    @instance_threads << Thread.new { start_tester 4567, handin_path }
    @instance_threads << Thread.new { start_tester 4444, handin_path }
  end
  alias_method :pt2, :prepare_test2

  def kill_test2(args)
    @instance_threads.each do |thread|
      thread.kill
    end
  end
end
