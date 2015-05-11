# Tests writing on client and server to the same text area at the same time
# Easier than the test_simultaneous (ts)
# For solutions that have one shared text area that both the client and the
# server write to
class Commander
  def test_simultaneous_speed(args)
    server, client = if args.length == 2
                       args
                     else
                       ['0', '1']
                     end

    connect_client_and_server(client, server)

    do_simultaneous_typing(client, server, SLOW_TYPING)
    reconnect client, server
    do_simultaneous_typing(client, server, SLOWER_TYPING)
    reconnect client, server
    do_simultaneous_typing(client, server, LESS_SLOWER_TYPING)
    reconnect client, server
    do_simultaneous_typing(client, server, FAST_TYPING)
    reconnect client, server
    do_simultaneous_typing(client, server, REALLY_FAST_TYPING)

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :tss, :test_simultaneous_speed

  def prepare_test_simultaneous_speed(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :ptss, :prepare_test_simultaneous_speed

  private

  def do_simultaneous_typing(client, server, speed)
    testing "writing on the client and server at the same time, speed: #{speed}" do
      starting_text = 'aA' * 50
      write [ 0, client, starting_text ]
      additional_text_client = 'bB' * 50
      additional_text_server = 'cC' * 50

      wait 1

      set_caret [ client, 10 ]
      set_caret [ server, 40 ]

      wait 1

      t_client = Thread.new do
        write_with_speed [-1, client, speed, additional_text_client]
      end
      wait 1
      t_server = Thread.new do
        write_with_speed [-1, server, speed, additional_text_server]
      end

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'bB', 50, 'cC', 50)
    end
  end

  def reconnect(client, server)
    testing "reconnecting" do
      disconnect [ server ]
      connect_client_and_server(client, server)
    end
  end
end
