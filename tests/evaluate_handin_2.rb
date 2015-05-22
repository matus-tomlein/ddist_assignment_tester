# Tests run in order the evaluate the second handin
class Commander
  def evaluate_handin_2(args)
    server, client = if args.length == 2
                       args
                     else
                       ['0', '1']
                     end

    connect_client_and_server(client, server)

    results = []
    [
      { speed: SLOWER_TYPING, client_caret: 10, server_caret: 20, delay: 0 },
      { speed: SLOWER_TYPING, client_caret: 0, server_caret: 1, delay: 0 },

      { speed: LESS_SLOWER_TYPING, client_caret: 10, server_caret: 20, delay: 0 },
      { speed: LESS_SLOWER_TYPING, client_caret: 0, server_caret: 1, delay: 0 },

      { speed: FAST_TYPING, client_caret: 10, server_caret: 20, delay: 0 },
      { speed: FAST_TYPING, client_caret: 0, server_caret: 1, delay: 0 },

      { speed: SLOWER_TYPING, client_caret: 10, server_caret: 20, delay: THROTTLING_SLOW },
      { speed: SLOWER_TYPING, client_caret: 0, server_caret: 1, delay: THROTTLING_SLOW },

      { speed: LESS_SLOWER_TYPING, client_caret: 10, server_caret: 20, delay: THROTTLING_SLOW },
      { speed: LESS_SLOWER_TYPING, client_caret: 0, server_caret: 1, delay: THROTTLING_SLOW },

      { speed: FAST_TYPING, client_caret: 10, server_caret: 20, delay: THROTTLING_SLOW },
      { speed: FAST_TYPING, client_caret: 0, server_caret: 1, delay: THROTTLING_SLOW }
    ].each do |config|
      2.times do |i|
        testing "writing simultaneously, speed: #{config[:speed]}, offset on client: #{config[:client_caret]}, offset on server: #{config[:server_caret]}, delay: #{config[:delay]} attempt: #{i}" do
          results << {
            config: config,
            attempt: i,
            results: type_simultaneously_and_return_results(
              client, server,
              config[:client_caret],
              config[:server_caret],
              config[:speed],
              config[:delay]
            )
          }
        end
        clear_text_area(client, server)
      end
    end

    shutdown [ client ]
    shutdown [ server ]

    puts
    puts 'speed,distance,delay,attempt,levenshtein,client_success,server_success'
    results.each do |result|
      caret_distance = result[:config][:server_caret] - result[:config][:client_caret]
      levenshtein, client_text_on_server, server_text_on_client = 'F', 'F', 'F'
      if result[:results]
        levenshtein = result[:results][:levenshtein_distance]
        client_text_on_server = result[:results][:client_text_on_server]
        server_text_on_client = result[:results][:server_text_on_client]
      end

      puts "#{result[:config][:speed]},#{caret_distance},#{result[:config][:delay]},#{result[:attempt]},#{levenshtein},#{client_text_on_server},#{server_text_on_client}"
    end
    puts
  end
  alias_method :eh2, :evaluate_handin_2

  def type_simultaneously_and_return_results(client, server,
                                             client_caret, server_caret,
                                             speed, delay)
    result = nil
    begin
      throttle [ client, 'download', delay ]
      throttle [ client, 'upload', delay ]

      result = type_simultaneously(client, server,
                                   client_caret, server_caret,
                                   delay == 0 ? 1 : 5,
                                   speed)
    rescue SimultaneousTextCompareError => error
      puts error.message.red
      result = error.results
    rescue => ex
      puts ex.message
    ensure
      throttle [ client, 'download', 0 ]
      throttle [ client, 'upload', 0 ]
    end
    result
  end

  def prepare_evaluate_handin_2(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :peh2, :prepare_evaluate_handin_2
end
