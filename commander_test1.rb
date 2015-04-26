class Commander
  def test1(args)
    server, client, second_server = if args.length == 3
                                      args
                                    else
                                      ['0', '1', '2']
                                    end

    testing 'starting listening on server 1' do
      listen [server]
    end
    wait 1

    testing 'connecting client to server 1' do
      connect [client, server]
    end
    wait 1

    testing 'writing a message on client' do
      test_writing_message client, server
    end
    wait 1

    testing 'updating the message on client' do
      test_writing_message client, server
    end
    wait 1

    testing 'writing a message on server 1' do
      test_writing_message server, client
    end
    wait 1

    testing 'updating the message on server 1' do
      test_writing_message server, client
    end

    testing 'disconnecting client from server 1' do
      disconnect [client]
    end

    testing 'starting listening on server 2' do
      listen [second_server]
    end
    wait 1

    testing 'connecting client to server 2' do
      connect [client, second_server]
    end
    wait 1

    testing 'writing a message on client' do
      test_writing_message client, second_server
    end
    wait 1

    testing 'updating the message on client' do
      test_writing_message client, second_server
    end
    wait 1

    testing 'writing a message on server 2' do
      test_writing_message second_server, client
    end
    wait 1

    testing 'updating the message on server 2' do
      test_writing_message second_server, client
    end

    testing 'disconnecting client' do
      disconnect [client]
    end
    wait 1

    testing 'connecting client to server 2 again' do
      connect [client, second_server]
    end
    wait 1

    testing 'writing a message on server 2' do
      test_writing_message second_server, client
    end
    wait 1

    testing 'writing a message on client' do
      test_writing_message client, second_server
    end

    overview
  end
  alias_method :t1, :test1

  def prepare_test1(args)
    @instance_threads = []
    @instance_threads << Thread.new { `ruby tester.rb 4567` }
    @instance_threads << Thread.new { `ruby tester.rb 4444` }
    @instance_threads << Thread.new { `ruby tester.rb 5555` }
  end
  alias_method :pt1, :prepare_test1

  def kill_test1(args)
    @instance_threads.each do |thread|
      thread.kill
    end
  end

  private

  def test_writing_message(reader, writer, length = 50)
    new_text = generate_string length
    previous_text = read_area1 [writer]
    caret = previous_text == '' ? 0 : rand(previous_text.size)
    expected_text = previous_text.insert caret, new_text

    write([caret, writer, new_text])
    wait 1
    text = read [reader]

    if text != expected_text
      raise "Expected '#{expected_text}' but got '#{text}''"
    end

    true
  end

  def generate_string(length)
    (0...length).map { (65 + rand(26)).chr }.join
  end
end
