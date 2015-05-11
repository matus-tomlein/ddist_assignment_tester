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
      starting_text = 'A' * 300
      write [ 0, client, starting_text ]
      additional_text_client = 'B' * 200
      additional_text_server = 'C' * 200

      wait 1

      set_caret [ client, 100 ]
      set_caret [ server, 200 ]

      t_client = Thread.new { write [-1, client, additional_text_client] }
      t_server = Thread.new { write [-1, server, additional_text_server] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'B', 200, 'C', 200)
    end

    testing "writing closer together" do
      set_caret [ client, 10 ]
      set_caret [ server, 20 ]

      write_client = 'DENMARK' * 40
      write_server = 'SLOVAKIA' * 40
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'DENMARK', 40, 'SLOVAKIA', 40)
    end

    testing "writing really close together - 1 space apart" do
      set_caret [ client, 0 ]
      set_caret [ server, 1 ]

      write_client = 'KRASA' * 40
      write_server = 'UZASNE' * 40
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'KRASA', 40, 'UZASNE', 40)
    end

    testing "writing in the same place" do
      set_caret [ client, 0 ]
      set_caret [ server, 0 ]

      write_client = 'FANTAZIA' * 40
      write_server = 'POHODA' * 40
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'FANTAZIA', 40, 'POHODA', 40)
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
