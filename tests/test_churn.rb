class Commander
  def test_churn(args)
    test_churn_1(args)
    test_churn_2(args)
  end
  alias_method :tc, :test_churn

  def test_churn_1(args)
    testing '"churn"' do
      listen [ 'node_0' ]
      connect [ 'node_1', 'node_0' ]
      connect [ 'node_2', 'node_0' ]
      wait 1

      write [ 0, 'node_1', 'A' * 10 ]
      wait 1

      connect [ 'node_3', 'node_0' ]
      connect [ 'node_4', 'node_0' ]
      wait 1

      text = read [ 'node_3' ]
      expected_text = 'A' * 10
      raise "Existing text was not transferred after connecting: #{text} instead of #{expected_text}" unless expected_text == text
      text = read [ 'node_4' ]
      raise "Existing text was not transferred after connecting: #{text} instead of #{expected_text}" unless expected_text == text

      disconnect [ 'node_2' ]
      write [ 0, 'node_3', 'B' * 10 ]
      wait 1

      connect [ 'node_2', 'node_0' ]
      wait 1

      text = read [ 'node_2' ]
      expected_text = 'B' * 10 + 'A' * 10
      raise "Text written while disconnected was not transferred after connecting: #{text} instead of #{expected_text}" unless expected_text == text

      5.times do |i|
        disconnect [ "node_#{i}" ]
      end
    end
  end
  alias_method :tc1, :test_churn_1

  def test_churn_2(args)
    testing 'disconnecting the server' do
      listen [ 'node_4' ]

      4.times do |i|
        connect [ "node_#{i}", 'node_4' ]
      end
      wait 3

      write [ 0, 'node_3', 'X' * 10 ]
      wait 3

      disconnect [ 'node_4' ]
      wait 3

      write [ 0, 'node_1', 'Y' * 10 ]
      wait 3

      expected_text = 'Y' * 10 + 'X' * 10
      4.times do |i|
        text = read [ "node_#{i}" ]
        raise "Node #{i} has #{text} instead of #{expected_text}" unless expected_text == text
      end
    end

    5.times do |i|
      shutdown [ "node_#{i}" ]
    end

    overview
  end
  alias_method :tc2, :test_churn_2

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
