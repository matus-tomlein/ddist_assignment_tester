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

    connect_client_and_server(client, server)

    testing "writing on the client and server at the same time, far apart" do
      type_simultaneously(client, server, 5, 95)
    end

    clear_text_area(client, server)

    testing "writing closer together" do
      type_simultaneously(client, server, 10, 20)
    end

    clear_text_area(client, server)

    testing "writing really close together - 1 space apart" do
      type_simultaneously(client, server, 0, 1)
    end

    clear_text_area(client, server)

    testing "writing in the same place" do
      type_simultaneously(client, server, 0, 0)
    end

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :ts, :test_simultaneous

  def type_simultaneously(client, server, client_caret, server_caret, waiting_time = 1, typing_speed = LESS_SLOWER_TYPING)
    starting_text = 'O' * ([ client_caret, server_caret].max + 5)
    write [ 0, client, starting_text ]

    wait waiting_time

    additional_text_client = 'abcd' * 50
    additional_text_server = '1234' * 50

    set_caret [ client, client_caret ]
    set_caret [ server, server_caret ]

    t_client = Thread.new do
      write_with_speed [-1, client, typing_speed, additional_text_client]
    end
    t_server = Thread.new do
      write_with_speed [-1, server, typing_speed, additional_text_server]
    end

    t_client.join
    t_server.join

    wait waiting_time

    text_on_client = read_area1 [client]
    text_on_server = read_area1 [server]

    compare_texts(text_on_client, text_on_server, 'abcd', 50, '1234', 50)
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
