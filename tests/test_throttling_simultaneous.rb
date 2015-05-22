# Test simultaneous typing on client and server with different
# network speeds (network traffic is throttled)
class Commander
  def test_throttling_simultaneous(args)
    server, client = if args.length == 2
                       args
                     else
                       ['0', '1']
                     end

    connect_client_and_server(client, server)

    testing "slowing down all the traffic - a bit" do
      throttle [ client, 'download', THROTTLING_A_BIT ]
      throttle [ client, 'upload', THROTTLING_A_BIT ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    dont_throttle(client)
    clear_text_area(client, server)

    testing "slowing down all the traffic - more" do
      throttle [ client, 'download', THROTTLING_SLOW ]
      throttle [ client, 'upload', THROTTLING_SLOW ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    dont_throttle(client)
    clear_text_area(client, server)

    testing "slowing down all the traffic - a lot" do
      throttle [ client, 'download', THROTTLING_VERY_SLOW ]
      throttle [ client, 'upload', THROTTLING_VERY_SLOW ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    dont_throttle(client)
    clear_text_area(client, server)

    testing "slowing down upload on client - a bit" do
      throttle [ client, 'upload', THROTTLING_A_BIT ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    dont_throttle(client)
    clear_text_area(client, server)

    testing "slowing down upload on client - more" do
      throttle [ client, 'upload', THROTTLING_SLOW ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    dont_throttle(client)
    clear_text_area(client, server)

    testing "slowing down upload on client - a lot" do
      throttle [ client, 'upload', THROTTLING_VERY_SLOW ]
      type_simultaneously(client, server, 5, 95, 5)
    end

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :tts, :test_throttling_simultaneous

  def dont_throttle(client)
    begin
      throttle [ client, 'download', 0 ]
      throttle [ client, 'upload', 0 ]
    rescue => ex
      puts ex.message
    end
  end

  def prepare_test_throttling_simultaneous(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :ptts, :prepare_test_throttling_simultaneous
end
