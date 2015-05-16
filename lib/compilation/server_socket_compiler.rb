class ServerSocketCompiler
  def initialize(folder)
    @folder = folder
  end

  def compile
    replace_class_constructor('ServerSocket', 'java.net.ServerSocket', 'ProxiedServerSocket')
    replace_class_constructor('Socket', 'java.net.Socket', 'ProxiedSocket')
    `mkdir #{@folder}/tester`
    `cp lib/handin_extensions/*.java #{@folder}/tester`
  end

  private

  def replace_class_constructor(old_class, old_class_with_module, new_class)
    Dir.glob("#{@folder}/**/*.java") do |file|
      File.open(file) do |source_file|
        contents = source_file.read
        new_contents = contents.gsub("new #{old_class}", "new tester.#{new_class}").
          gsub("new #{old_class_with_module}", "new tester.#{new_class}")

        if new_contents != contents
          File.open(file, "w+") { |f| f.write(new_contents) }
        end
      end
    end
  end
end
