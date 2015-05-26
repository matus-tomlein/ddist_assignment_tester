class Commander
  def test_churn(args)
    node_0, node_1, node_2, node_3, node_4 = if args.length == 4
                                       args
                                     else
                                       [ 'node_0', 'node_1', 'node_2', 'node_3', 'node_4' ]
                                     end

    testing '"churn"' do
      listen [ node_0 ]
      connect [ node_1, node_0 ]
      wait 1

      # Start typing a long text
      text = 'abcd'
      repetitions = 90

      typer_thread = Thread.new do
        write_repeatedly [ 0, node_1, text, repetitions, FAST_TYPING ]
      end

      wait 2

      connect [ node_2, node_0 ]
      wait 2

      connect [ node_3, node_0 ]
      wait 2

      connect [ node_4, node_0 ]
      wait 2

      disconnect [ node_3 ]
      wait 2

      connect [ node_3, node_0 ]
      wait 2

      disconnect [ node_0 ]
      wait 2

      disconnect [ node_2 ]

      typer_thread.join
      wait 5

      text_node_1 = read_area1 [ node_1 ]
      text_node_3 = read_area1 [ node_3 ]
      text_node_4 = read_area1 [ node_4 ]

      compare_texts_to_expected({
        node_1 => text_node_1,
        node_3 => text_node_3,
        node_4 => text_node_4
      }, text, repetitions)
    end

    [ node_0, node_1, node_2, node_3, node_4].each do |node|
      shutdown [ node ]
    end
  end
  alias_method :tc, :test_churn

  def prepare_test_churn(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    5.times do |i|
      port = 5000 + i * 100
      add [ '127.0.0.1', port, "node_#{i}" ]
      Thread.new { start_tester port, handin_path }
    end
  end
  alias_method :ptc, :prepare_test_churn
end
