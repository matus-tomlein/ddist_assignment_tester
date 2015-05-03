class Commander
  def test_multiple_simultaneous(args)
    test_multiple_simultaneous_2(args)
    test_multiple_simultaneous_3(args)
    test_multiple_simultaneous_4(args)
  end
  alias_method :tms, :test_multiple_simultaneous

  def test_multiple_simultaneous_2(args)
    start_up

    testing '2 simultaneous editings' do
      writer1 = 'node_0'
      writer2 = 'node_1'
      text1 = 'xX' * 10
      text2 = 'yY' * 10

      set_caret [ writer1, 0 ]
      set_caret [ writer2, 0 ]

      wait 1

      t1 = Thread.new { write [ -1, writer1, text1 ] }
      t2 = Thread.new { write [ -1, writer2, text2 ] }

      t1.join
      t2.join

      wait 10

      text_server = read [ 'node_0' ]

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is garbled: #{read_text}" unless read_text.include? text1
        raise "Text is garbled: #{read_text}" unless read_text.include? text2
      end

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is not consistent accross nodes (but otherwise OK)): #{read_text} instead of #{text_server}" if read_text != text_server
      end
    end

    finish
  end
  alias_method :tms2, :test_multiple_simultaneous_2

  def test_multiple_simultaneous_3(args)
    start_up

    testing '3 simultaneous editings' do
      writer1 = 'node_0'
      writer2 = 'node_1'
      writer3 = 'node_2'
      text1 = 'aA' * 5
      text2 = 'bB' * 5
      text3 = 'cC' * 5

      set_caret [ writer1, 0 ]
      set_caret [ writer2, 0 ]
      set_caret [ writer3, 0 ]

      wait 1

      t1 = Thread.new { write [ -1, writer1, text1 ] }
      t2 = Thread.new { write [ -1, writer2, text2 ] }
      t3 = Thread.new { write [ -1, writer3, text3 ] }

      t1.join
      t2.join
      t3.join

      wait 10

      text_server = read [ 'node_0' ]

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is garbled: #{read_text}" unless read_text.include? text1
        raise "Text is garbled: #{read_text}" unless read_text.include? text2
        raise "Text is garbled: #{read_text}" unless read_text.include? text3
      end

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is not consistent accross nodes (but otherwise OK)): #{read_text} instead of #{text_server}" if read_text != text_server
      end
    end

    finish
  end
  alias_method :tms3, :test_multiple_simultaneous_3

  def test_multiple_simultaneous_4(args)
    start_up

    testing '4 simultaneous editings' do
      writer1 = 'node_0'
      writer2 = 'node_1'
      writer3 = 'node_2'
      writer4 = 'node_3'
      text1 = 'dD' * 5
      text2 = 'eE' * 5
      text3 = 'fF' * 5
      text4 = 'gG' * 5

      set_caret [ writer1, 0 ]
      set_caret [ writer2, 0 ]
      set_caret [ writer3, 0 ]
      set_caret [ writer4, 0 ]

      wait 1

      t1 = Thread.new { write [ -1, writer1, text1 ] }
      t2 = Thread.new { write [ -1, writer2, text2 ] }
      t3 = Thread.new { write [ -1, writer3, text3 ] }
      t4 = Thread.new { write [ -1, writer4, text4 ] }

      t1.join
      t2.join
      t3.join
      t4.join

      wait 10

      text_server = read [ 'node_0' ]

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is garbled: #{read_text}" unless read_text.include? text1
        raise "Text is garbled: #{read_text}" unless read_text.include? text2
        raise "Text is garbled: #{read_text}" unless read_text.include? text3
        raise "Text is garbled: #{read_text}" unless read_text.include? text4
      end

      4.times do |i|
        read_text = read [ "node_#{i}" ]
        raise "Text is not consistent accross nodes (but otherwise OK): #{read_text} instead of #{text_server}" if read_text != text_server
      end
    end

    4.times do |i|
      shutdown [ "node_#{i}" ]
    end

    finish
  end
  alias_method :tms4, :test_multiple_simultaneous_4

  def start_up
    testing 'connecting the nodes' do
      listen [ 'node_0' ]
      connect [ 'node_1', 'node_0' ]
      connect [ 'node_2', 'node_0' ]
      connect [ 'node_3', 'node_0' ]
      wait 2
    end
  end

  def finish
    testing 'disconnecting' do
      4.times do |i|
        disconnect [ "node_#{i}" ]
      end
    end

    overview
  end

  def prepare_test_multiple_simultaneous(args)
    handin_path = 'handin'
    if args.any?
      handin_path = args.first
      puts "Using handin path: #{handin_path}"
    end

    4.times do |i|
      port = 5000 + i * 100
      add [ '127.0.0.1', port, "node_#{i}" ]
      Thread.new { start_tester port, handin_path }
    end
  end
  alias_method :ptms, :prepare_test_multiple_simultaneous
end
