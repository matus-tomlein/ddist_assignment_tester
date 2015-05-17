# Test simultaneous typing on client and server while the
# messages arrive on the server in a shuffled order
class Commander
  def test_reordering_simultaneous(args)
    server, client = if args.length == 2
                       args
                     else
                       ['0', '1']
                     end

    connect_client_and_server(client, server)

    testing "reordering messages - small window" do
      shuffle [ server, REORDERING_SMALL_WINDOW ]
      shuffle [ client, REORDERING_SMALL_WINDOW ]
      type_simultaneously(client, server, 5, 95, 5)
      shuffle [ server, 0 ]
      shuffle [ client, 0 ]
    end

    clear_text_area(client, server)

    testing "reordering messages - bigger window" do
      shuffle [ server, REORDERING_BIGGER_WINDOW ]
      shuffle [ client, REORDERING_BIGGER_WINDOW ]
      type_simultaneously(client, server, 5, 95, 5)
      shuffle [ server, 0 ]
      shuffle [ client, 0 ]
    end

    clear_text_area(client, server)

    testing "reordering messages - large window" do
      shuffle [ server, REORDERING_LARGE_WINDOW ]
      shuffle [ client, REORDERING_LARGE_WINDOW ]
      type_simultaneously(client, server, 5, 95, 5)
      shuffle [ server, 0 ]
      shuffle [ client, 0 ]
    end

    shutdown [ client ]
    shutdown [ server ]

    overview
  end
  alias_method :trs, :test_reordering_simultaneous

  def prepare_test_reordering_simultaneous(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    Thread.new { start_tester 4567, handin_path }
    Thread.new { start_tester 4444, handin_path }
  end
  alias_method :ptrs, :prepare_test_reordering_simultaneous
end
