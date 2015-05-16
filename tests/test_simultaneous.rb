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
      additional_text_client = 'abcd' * 50
      additional_text_server = '1234' * 50

      set_caret [ client, 5 ]
      set_caret [ server, 95 ]

      t_client = Thread.new { write [-1, client, additional_text_client] }
      t_server = Thread.new { write [-1, server, additional_text_server] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'abcd', 50, '1234', 50)
    end

    clear_text_area(client, server)
    write_initial_text(client, server)

    testing "writing closer together" do
      set_caret [ client, 10 ]
      set_caret [ server, 20 ]

      write_client = 'abcd' * 50
      write_server = '1234' * 50
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'abcd', 50, '1234', 50)
    end

    clear_text_area(client, server)
    write_initial_text(client, server)

    testing "writing really close together - 1 space apart" do
      set_caret [ client, 0 ]
      set_caret [ server, 1 ]

      write_client = 'abcd' * 50
      write_server = '1234' * 50
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'abcd', 50, '1234', 50)
    end

    clear_text_area(client, server)
    write_initial_text(client, server)

    testing "writing in the same place" do
      set_caret [ client, 0 ]
      set_caret [ server, 0 ]

      write_client = 'abcd' * 50
      write_server = '1234' * 50
      t_client = Thread.new { write [-1, client, write_client ] }
      t_server = Thread.new { write [-1, server, write_server ] }

      t_client.join
      t_server.join

      wait 1

      text_on_client = read_area1 [client]
      text_on_server = read_area1 [server]

      compare_texts(text_on_client, text_on_server, 'abcd', 50, '1234', 50)
    end

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :ts, :test_simultaneous

  def ts_start_up(client, server)
    connect_client_and_server(client, server)
    write_initial_text(client, server)
  end

  def write_initial_text(client, server)
    testing 'writing the initial text' do
      starting_text = 'O' * 100
      write [ 0, client, starting_text ]
      wait 1
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
