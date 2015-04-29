class SimulatedEditorAccess
  def initialize(compiled_folder)
    @compiled_folder = compiled_folder
  end

  def compile
    `cd #{@compiled_folder} && javac *.java`

    $CLASSPATH << @compiled_folder
    java_import 'Simulated'

    @simulated = Simulated.new
    @simulated.init
  end

  def lower_text_area
    @simulated.getLowerTextArea
  end

  def upper_text_area
    @simulated.getUpperTextArea
  end

  def start_listening(port)
    @port = port
    listening_port = @simulated.startListening(port.to_i)
    @port = listening_port if listening_port
  end

  def connect(ip, port)
    @port = port
    @simulated.connect(ip, port.to_i)
  end

  def disconnect
    @simulated.disconnect
  end

  def current_port
    @port
  end
end
