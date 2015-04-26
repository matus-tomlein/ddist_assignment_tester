require 'fileutils'

class Compiler
  def initialize(handin_path)
    @handin_path = handin_path
    subfolder = (0...8).map { (65 + rand(26)).chr }.join
    @compiled_folder = "handin-compiled/#{subfolder}"
    puts @compiled_folder
  end

  def self.run(handin_path, &block)
    compiler = self.new(handin_path)
    compiler.start(&block)
    compiler
  end

  def start(&block)
    copy
    compile
    begin
      yield(create_editor)
    rescue => ex
      puts ex.message
      puts ex.backtrace.join("\n")
    end
  end

  private

  def create_editor
    $CLASSPATH << @compiled_folder
    java_import 'DistributedTextEditor'
    DistributedTextEditor.main nil
    DistributedTextEditor::_instance
  end

  def copy
    remove_compiled if File.exist?(@compiled_folder)
    FileUtils.mkpath(@compiled_folder)
    FileUtils.copy_entry @handin_path, @compiled_folder
  end

  def compile
    main_class_file_name = "#{@compiled_folder}/DistributedTextEditor.java"
    source_code = File.read(main_class_file_name)
    File.open(main_class_file_name, 'w') do |file|
      file.puts(add_getters_to_source_code(source_code))
    end

    `cd #{@compiled_folder} && javac *.java`
  end

  def add_getters_to_source_code(source_code)
    source_code.sub(
      'class DistributedTextEditor extends JFrame {',
      'class DistributedTextEditor extends JFrame {
   public JTextArea _getArea1() { return this.area1; }
   public JTextArea _getArea2() { return this.area2; }
   public JTextField _getIPAddressField() { return this.ipaddress; }
   public JTextField _getPortNumberField() { return this.portNumber; }
   public Action _getListenAction() { return this.Listen; }
   public Action _getConnectAction() { return this.Connect; }
   public Action _getDisconnectAction() { return this.Disconnect; }
   public static DistributedTextEditor _instance;'
    ).sub(
      'DistributedTextEditor() {',
      'DistributedTextEditor() { DistributedTextEditor._instance = this;'
      ).sub(
        'void saveOld() {',
        'void saveOld() { if (1 == 1) { return; }'
      )
  end

  def remove_compiled
    FileUtils.rm_rf @compiled_folder
  end
end
