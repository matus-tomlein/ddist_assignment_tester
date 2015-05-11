# Tests writing on client and server to the same text area at the same time
# For solutions that have one shared text area that both the client and the
# server write to
class Commander
  def test_simultaneous(args)
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

    testing "writing on the client and server at the same time, far apart" do
      starting_text = 'A' * 200
      write [ 0, client, starting_text ]
      additional_text_client = 'bB' * 100
      additional_text_server = 'cC' * 100

      wait 1

      set_caret [ client, 50 ]
      set_caret [ server, 150 ]

      t_client = Thread.new { write [-1, client, additional_text_client] }
      t_server = Thread.new { write [-1, server, additional_text_server] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'bB', 100, 'cC', 100)
    end

    testing "writing closer together" do
      set_caret [ client, 10 ]
      set_caret [ server, 20 ]

      write_client = 'xX' * 100
      write_server = 'yY' * 100
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'xX', 100, 'yY', 100)
    end

    testing "writing really close together - 1 space apart" do
      set_caret [ client, 0 ]
      set_caret [ server, 1 ]

      write_client = 'mM' * 100
      write_server = 'nN' * 100
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'mM', 100, 'nN', 100)
    end

    testing "writing in the same place" do
      set_caret [ client, 0 ]
      set_caret [ server, 0 ]

      write_client = 'fF' * 100
      write_server = 'gG' * 100
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'fF', 100, 'gG', 100)
    end

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :ts, :test_simultaneous

  def prepare_test_simultaneous(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :pts, :prepare_test_simultaneous
end
