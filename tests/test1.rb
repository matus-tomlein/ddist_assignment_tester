# Basic test for the first handin
# Connects client to server 1 and exchanges messages
# Disconnects them
# Connects client to server 2 and exchanges messages
# Disconnects the client and reconnects to server 2
# Exchanges messages
class Commander
  def test1(args)
    server, client, second_server = if args.length == 3
                                      args
                                    else
                                      ['0', '1', '2']
                                    end

    connect_client_and_server client, server

    testing 'writing a message on client' do
      test_writing_message client, server
    end
    wait 1

    testing 'updating the message on client' do
      test_writing_message client, server
    end
    wait 1

    testing 'writing a message on server 1' do
      test_writing_message server, client
    end
    wait 1

    testing 'updating the message on server 1' do
      test_writing_message server, client
    end

    testing 'disconnecting client from server 1' do
      disconnect [client]
    end

    t_listen = Thread.new do
      testing 'starting listening on server 2' do
        listen_and_update_port second_server
      end
    end
    wait 3

    t_connect = Thread.new do
      testing 'connecting client to server 2' do
        connect [client, second_server]
      end
    end
    wait 1

    t_listen.join
    t_connect.join

    testing 'writing a message on client' do
      test_writing_message client, second_server
    end
    wait 1

    testing 'updating the message on client' do
      test_writing_message client, second_server
    end
    wait 1

    testing 'writing a message on server 2' do
      test_writing_message second_server, client
    end
    wait 1

    testing 'updating the message on server 2' do
      test_writing_message second_server, client
    end

    testing 'disconnecting client' do
      disconnect [client]
    end
    wait 1

    testing 'connecting client to server 2 again' do
      connect [client, second_server]
    end
    wait 1

    testing 'writing a message on server 2' do
      test_writing_message second_server, client
    end
    wait 1

    testing 'writing a message on client' do
      test_writing_message client, second_server
    end

    overview

    shutdown [ client ]
    shutdown [ server ]
    shutdown [ second_server ]
  end
  alias_method :t1, :test1

  def prepare_test1(args)
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
  alias_method :pt1, :prepare_test1

  def kill_test1(args)
    @instance_threads.each do |thread|
      thread.kill
    end
  end
end
