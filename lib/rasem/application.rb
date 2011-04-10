class Rasem::Application
  def self.run!(*argv)
    if argv.empty?
      source_files = Dir.glob(File.expand_path("*.rasem"))
    else
      source_files = argv
    end

    if source_files.empty?
      puts "No input files"
      return 1
    end

    for source_file in source_files
      puts "Source file #{source_file}"
      if source_file =~ /\.rasem$/
        svg_file = source_file.sub(/\.rasem$/, '.svg')
      else
        svg_file = source_file + ".svg"
      end
      File.open(svg_file, "w") do |f|
        Rasem::SVGImage.new(f, 100, 100) do
          eval(File.read(source_file), binding)
        end
      end
    end
    
    return 0
  end
end
