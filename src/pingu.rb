require 'find'
require "benchmark"

class Main
  
  attr_reader :total_files, :total_folders, :total_size, :ignored_count
  
  def initialize()
    @file_size = 0
    @total_size = 0
    @total_files = 0
    @total_folders = 0
    @file_array = []
    @ignored_count = 0
  end

  def scan(path)
    Dir.chdir(path)
    
    dir =  Dir.glob("*")
  
    Find.find(Dir.pwd) do |file_path|

      if File.file?(file_path)
        file_size = File.size(file_path)
        @total_size +=  file_size
        @total_files += 1
        @file_array << [file_path, file_size]
      elsif File.directory?(file_path)
        @total_folders +=1
      else
        @ignored_count += 1
        puts file_path + " ignorado!"
      end

    end

  end

end

#
#

class Pingu
  def initialize
    @total_size = 0
    @number_files = 0
    @file_array = []
  end

  # Recursevely scan a filesystem to retrieve all files plus the corresponding
  # filesize
  def scan(option = {})
    filesystem = option[:filesystem] || "/"
    Find.find(filesystem) do |path|
      if File.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune  # Don't look any further into this directory.
        else
          next
        end
      else
        #if not File.symlink?(path)
          @number_files += 1
          file_size = File.size(path)
          @total_size += file_size
          @file_array << [path, file_size]
        #end
      end
    end

    # Debug
    puts "Number of files: #{@number_files}"
    puts "Total size: #{@total_size}"
    puts "File array: "
    #@file_array.each {|file,size| puts "  #{file}: #{size}"}
  end
end

Benchmark.bmbm do |x|
  x.report("### khani3s\n") {
    m = Main.new
    m.scan(ARGV[0])
    puts "#{m.total_size.to_f/(1024*1024)} MBytes em #{m.total_folders} diretorios e #{m.total_files} arquivos. #{m.ignored_count} ignorados."
  }
  x.report("### rebellis\n")  {
  p = Pingu.new
  p.scan Hash[:filesystem => ARGV[0]]
  }
  x.report("###khani3s magic\n"){
    dir_size = 0
    dir_count = 0
    file_count = 0
    ignored_count = 0

    file_array  = []
    Find.find(ARGV[0]) do |f|
      if File.file?(f)
        file_size = File.stat(f).size
        dir_size += file_size 
        file_count += 1
        file_array << [f, file_size]
      elsif File.directory?(f)
        dir_count += 1
      else
        ignored_count += 1 
      end
    end
    puts "#{dir_size.to_f/(1024*1024)} MBytes em #{dir_count} diretorios e #{file_count} arquivos. #{ignored_count} ignorados."
  }
end

