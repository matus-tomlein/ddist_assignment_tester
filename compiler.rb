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
    find_subfolder
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
    if @subfolder
      java_import "#{@subfolder}.DistributedTextEditor"
    else
      java_import 'DistributedTextEditor'
    end
    DistributedTextEditor.main nil
    DistributedTextEditor::_instance
  end

  def copy
    remove_compiled if File.exist?(@compiled_folder)
    FileUtils.mkpath(@compiled_folder)
    FileUtils.copy_entry @handin_path, @compiled_folder
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

  def compile
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

    `cd #{code_folder} && javac *.java`
  end

  def add_getters_to_source_code(source_code)
    i_class = source_code.index('class DistributedTextEditor')
    raise 'class DistributedTextEditor not found in source code' unless i_class
    i_class = source_code.index('{', i_class)
    raise 'class DistributedTextEditor not found in source code' unless i_class

    source_code = source_code.insert(i_class + 1, 'public JTextArea _getArea1() { return this.area1; }
   public JTextArea _getArea2() { return this.area2; }
   public JTextField _getIPAddressField() { return this.ipaddress; }
   public JTextField _getPortNumberField() { return this.portNumber; }
   public static DistributedTextEditor _instance;')

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

  def remove_compiled
    FileUtils.rm_rf @compiled_folder
  end
end
