require 'fileutils'

class Compiler
  def self.run
    copy
    compile
    begin
      yield
    rescue; end
    remove_compiled
  end

  private

  def self.copy
    FileUtils.copy_entry 'handin', 'handin-compiled'
  end

  def self.compile
    main_class_file_name = 'handin-compiled/DistributedTextEditor.java'
    source_code = File.read(main_class_file_name)
    File.open(main_class_file_name, 'w') do |file|
      file.puts(add_getters_to_source_code(source_code))
    end

    `cd handin-compiled && javac *.java`
  end

  def self.add_getters_to_source_code(source_code)
    source_code.sub(
      'class DistributedTextEditor extends JFrame {',
      'class DistributedTextEditor extends JFrame {
   public JTextArea _getArea1() { return this.area1; }
   public JTextField _getIPAddressField() { return this.ipaddress; }
   public JTextField _getPortNumberField() { return this.portNumber; }
   public Action _getListenAction() { return this.Listen; }'
    )
  end

  def self.remove_compiled
    FileUtils.rm_rf 'handin-compiled'
  end
end
