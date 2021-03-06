class Commander
  def test_multiple_simultaneous(args)
    node_0, node_1, node_2, node_3 = if args.length == 4
                                       args
                                     else
                                       [ 'node_0', 'node_1', 'node_2', 'node_3' ]
                                     end

    text1_unit = 'abcd'
    text2_unit = '1234'
    text3_unit = 'ABCD'
    text4_unit = '9876'
    repetitions = 20

    text1 = text1_unit * repetitions
    text2 = text2_unit * repetitions
    text3 = text3_unit * repetitions
    text4 = text4_unit * repetitions

    testing 'connecting the nodes' do
      listen [ node_0 ]
      connect [ node_1, node_0 ]
      connect [ node_2, node_0 ]
      connect [ node_3, node_0 ]
      wait 2
    end

    testing '2 simultaneous editings' do
      write [ 0, node_0, 'O' * 10 ]
      wait 1

      set_caret [ node_0, 0 ]
      set_caret [ node_1, 5 ]

      wait 1

      t1 = Thread.new { write [ -1, node_0, text1 ] }
      t2 = Thread.new { write [ -1, node_1, text2 ] }

      t1.join
      t2.join

      wait 10

      text_server = read_area1([ node_0 ])

      [ node_0, node_1, node_2, node_3 ].each do |node|
        read_text = read_area1([ node ])
        compare_texts(read_text, text_server,
                      text2_unit, repetitions,
                      text1_unit, repetitions,
                      node, node_0)
      end
    end

    clear_text_area(node_0, node_1)

    testing '3 simultaneous editings' do
      write [ 0, node_0, 'O' * 15 ]
      wait 1

      set_caret [ node_0, 0 ]
      set_caret [ node_1, 5 ]
      set_caret [ node_2, 10 ]

      wait 1

      t1 = Thread.new { write [ -1, node_0, text1 ] }
      t2 = Thread.new { write [ -1, node_1, text2 ] }
      t3 = Thread.new { write [ -1, node_2, text3 ] }

      t1.join
      t2.join
      t3.join

      wait 10

      text_server = read_area1 [ node_0 ]

      [ node_0, node_1, node_2, node_3 ].each do |node|
        read_text = read_area1 [ node ]
        compare_texts(read_text, text_server,
                      text2_unit, repetitions,
                      text1_unit, repetitions,
                      node, node_0)
        compare_texts(read_text, text_server,
                      text2_unit, repetitions,
                      text3_unit, repetitions,
                      node, node_0)
      end
    end

    clear_text_area(node_0, node_1)

    testing '4 simultaneous editings' do
      write [ 0, node_0, 'O' * 15 ]
      wait 1

      set_caret [ node_0, 0 ]
      set_caret [ node_1, 5 ]
      set_caret [ node_2, 10 ]
      set_caret [ node_3, 15 ]

      wait 1

      t1 = Thread.new { write [ -1, node_0, text1 ] }
      t2 = Thread.new { write [ -1, node_1, text2 ] }
      t3 = Thread.new { write [ -1, node_2, text3 ] }
      t4 = Thread.new { write [ -1, node_3, text4 ] }

      t1.join
      t2.join
      t3.join
      t4.join

      wait 10

      text_server = read_area1 [ node_0 ]

      [ node_0, node_1, node_2, node_3 ].each do |node|
        read_text = read_area1([ node ])
        compare_texts(read_text, text_server,
                      text1_unit, repetitions,
                      text2_unit, repetitions,
                      node, node_0)
        compare_texts(read_text, text_server,
                      text3_unit, repetitions,
                      text4_unit, repetitions,
                      node, node_0)
      end
    end

    4.times do |i|
      shutdown [ "node_#{i}" ]
    end

    overview
  end
  alias_method :tms, :test_multiple_simultaneous

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
