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

    ts_start_up(client, server)

    testing "writing on the client and server at the same time, far apart" do
      additional_text_client = 'bB' * 100
      additional_text_server = 'cC' * 100

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

    finish(client, server)
    ts_start_up(client, server)

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

    finish(client, server)
    ts_start_up(client, server)

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

    finish(client, server)
    ts_start_up(client, server)

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

  def ts_start_up(client, server)
    connect_client_and_server(client, server)

    testing 'writing the initial text' do
      starting_text = 'A' * 200
      write [ 0, client, starting_text ]
      wait 1
    end
  end

  def finish(client, server)
    testing 'disconnecting' do
      disconnect [ server ]
    end
  end

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
