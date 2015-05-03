class ContentWatcher
  def initialize(text_area)
    @text_area = text_area
    @last_content = ''
  end

  def start_watching
    Thread.new do
      loop do
        content = @text_area.getText
        unless @last_content == content
          @last_content = content

          histogram = Hash.new(0)
          content.each_char { |char| histogram[char] += 1 }

          EventHistory.log_event({ type: :content_changed,
                                   chars: histogram })
        end
        sleep 0.1
      end
    end
  end
end
