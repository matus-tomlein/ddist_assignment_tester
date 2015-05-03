# Tests writing on client and server to the same text area at the same time
# For solutions that have one shared text area that both the client and the
# server write to
# I am not sure if the test is working, haven't yet tested it on a working
# solution
class Commander
  def test4(args)
    server, client = if args.length == 2
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

    testing "writing on the client and server at the same time" do
      starting_text = generate_string 300
      write [0, client, starting_text]
      additional_text_client = generate_string 200
      additional_text_server = generate_string 200
      expected_result = starting_text.insert 100, additional_text_client
      expected_result = expected_result.insert(200 + additional_text_client.size,
                                               additional_text_server)

      set_caret [client, 100]
      set_caret [server, 200]

      t_client = Thread.new do
        write [-1, client, additional_text_client]
      end

      t_server = Thread.new do
        write [-1, server, additional_text_server]
      end

      t_client.join
      t_server.join

      text_on_client = read [client]
      text_on_server = read [server]

      if text_on_server != expected_result
        raise "Text on server is wrong: #{text_on_server} instead of #{expected_result}"
      end

      if text_on_client != expected_result
        raise "Text on client is wrong: #{text_on_client} instead of #{expected_result}"
      end
    end

    overview
  end
  alias_method :t4, :test4

  def prepare_test4(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    @instance_threads = []
    @instance_threads << Thread.new { start_tester 4567, handin_path }
    @instance_threads << Thread.new { start_tester 4444, handin_path }
  end
  alias_method :pt4, :prepare_test4

  def kill_test4(args)
    @instance_threads.each do |thread|
      thread.kill
    end
  end
end
