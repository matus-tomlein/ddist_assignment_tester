require_relative 'server_socket_compiler'

class EditorAccess
  attr_reader :editor

  def initialize(compiled_folder)
    @compiled_folder = compiled_folder
  end

  def compile(instance_id)
    find_subfolder

    code_folder = if @subfolder
                    "#{@compiled_folder}/#{@subfolder}"
                  else
                    @compiled_folder
                  end
    main_class_file_name = "#{code_folder}/DistributedTextEditor.java"
    source_code = File.read(main_class_file_name)

    File.open(main_class_file_name, 'w') do |file|
      file.puts(add_getters_to_source_code(source_code))
    end

    ServerSocketCompiler.new(@compiled_folder).compile

    `cd #{code_folder} && javac *.java`

    create_editor(instance_id)
  end

  def lower_text_area
    editor._getArea2
  end

  def upper_text_area
    editor._getArea1
  end

  def start_listening(port)
    editor._getIPAddressField.setText('127.0.0.1')
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    trigger_listen_action
  end

  def connect(ip, port)
    editor._getIPAddressField.setText(ip.to_s)
    editor._getPortNumberField.setText(port.to_s)
    sleep(0.2)
    trigger_connect_action
  end

  def disconnect
    trigger_disconnect_action
  end

  def current_port
    editor._getPortNumberField.getText.to_i
  end

  def carret_changed
    if editor.respond_to? :carretChanged
      editor.carretChanged
    end
  end

  private

  def trigger_disconnect_action
    trigger_file_menu_action('Disconnect')
  end

  def trigger_connect_action
    trigger_file_menu_action('Connect')
  end

  def trigger_listen_action
    trigger_file_menu_action('Listen')
  end

  def trigger_file_menu_action(name)
    menu = editor.getJMenuBar.getMenu(0)
    menu.getItemCount.times do |i|
      item = menu.getItem(i)
      if item.getText.downcase.include?(name.downcase)
        item.doClick(200)
        return
      end
    end

    raise "Menu action #{name} not found"
  end

  def create_editor(instance_id)
    $CLASSPATH << @compiled_folder
    if @subfolder
      java_import "#{@subfolder}.DistributedTextEditor"
    else
      java_import 'DistributedTextEditor'
    end
    java_import 'TesterIdentifier'
    TesterIdentifier::id = instance_id
    DistributedTextEditor.main nil
    @editor = DistributedTextEditor::_instance
  end

  def find_subfolder
    unless File.exist? "#{@compiled_folder}/DistributedTextEditor.java"
      subfolders =  Dir.entries(@compiled_folder).select {|entry| File.directory? File.join(@compiled_folder, entry) and !(entry =='.' || entry == '..') }
      raise "DistributedTextEditor.java not found" unless subfolders.any?

      subfolders.each do |subfolder|
        if File.exist? "#{@compiled_folder}/#{subfolder}/DistributedTextEditor.java"
          @subfolder = subfolder
          return
        end
      end
      raise "DistributedTextEditor.java not found"
    end
  end

  def add_getters_to_source_code(source_code)
    i_class = source_code.index('class DistributedTextEditor')
    raise 'class DistributedTextEditor not found in source code' unless i_class
    i_class = source_code.index('{', i_class)
    raise 'class DistributedTextEditor not found in source code' unless i_class

    raise 'Variable with the name area1 not found in DistributedTextEditor' unless source_code.include? 'area1'

    getters = [
      'public JTextArea _getArea1() { return this.area1; }',
      'public JTextField _getIPAddressField() { return this.ipaddress; }',
      'public JTextField _getPortNumberField() { return this.portNumber; }',
      'public static DistributedTextEditor _instance;'
    ]

    if source_code.include? 'area2'
      getters << 'public JTextArea _getArea2() { return this.area2; }'
    else
      getters << 'public JTextArea _getArea2() { return this.area1; }'
    end

    source_code = source_code.insert(i_class + 1, getters.join("\n"))

    i = source_code.index('DistributedTextEditor()', i_class)
    raise 'DistributedTextEditor() not found in source code' unless i
    i = source_code.index('{', i)
    raise 'DistributedTextEditor() not found in source code' unless i

    source_code = source_code.insert(i + 1, 'DistributedTextEditor._instance = this;')

    i = source_code.index('void saveOld()', i_class)
    raise 'void saveOld() not found in source code' unless i
    i = source_code.index('{', i)
    raise 'void saveOld() not found in source code' unless i

    source_code = source_code.insert(i + 1, 'if (1 == 1) { return; }')
  end
end
