require_relative 'includes'

class Simulated
  def init
    @app = AppController.new
  end

  def getLowerTextArea
    @app.text_area
  end

  def getUpperTextArea
    @app.text_area
  end

  def startListening(port)
    @app.listen(port)
    port
  end

  def connect(ipAddress, port)
    @app.connect(ipAddress, port)
  end

  def disconnect
    @app.disconnect
  end
end
