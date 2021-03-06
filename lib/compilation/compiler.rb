require 'fileutils'

require_relative 'java_classes'
require_relative 'editor_access'
require_relative 'simulated_editor_access'

class Compiler
  def initialize(handin_path, instance_id)
    @handin_path = handin_path
    @instance_id = instance_id
    subfolder = (0...8).map { (65 + rand(26)).chr }.join
    @compiled_folder = "handin-compiled/#{subfolder}"
    puts @compiled_folder
  end

  def self.run(handin_path, instance_id, &block)
    compiler = self.new(handin_path, instance_id)
    compiler.start(&block)
    compiler
  end

  def start(&block)
    copy
    editor_access = compile
    begin
      yield(editor_access)
    rescue => ex
      puts ex.message
      puts ex.backtrace.join("\n")
    end
  end

  private

  def copy
    remove_compiled if File.exist?(@compiled_folder)
    FileUtils.mkpath(@compiled_folder)
    FileUtils.copy_entry @handin_path, @compiled_folder
  end

  def compile
    editor_access = if File.exist?("#{@compiled_folder}/Simulated.java")
                      SimulatedEditorAccess.new @compiled_folder
                    elsif File.exist?("#{@compiled_folder}/simulated.rb")
                      SimulatedEditorAccess.new @handin_path, true
                    else
                      EditorAccess.new @compiled_folder
                    end

    editor_access.compile(@instance_id)
    editor_access
  end

  def remove_compiled
    FileUtils.rm_rf @compiled_folder
  end
end
