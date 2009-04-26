# CFBackup, a small utility script to backup files to Mosso Cloud Files
#     Copyright (C) 2009  Jon Stacey
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'ftools'
require 'cloudfiles'
require 'OptCFBackup'
require 'yaml'

class CFBackup
  
  def initialize(args)
    @opts = OptCFBackup.new(args)

    # Special case if the version is requested
    if @opts.options.show_ver
      version_file = File.join(File.dirname(__FILE__), '..', 'VERSION.yml')
      if File.exist?(version_file)
        config = YAML.load(File.read(version_file))
        version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
      else
        version = "unkown version"
      end
      show_error("CFBackup #{version}")
    end
    
    # Locate and load config file
    @opts.options.config.each do |path|
      if (File.exist?(path))
        @conf = YAML::load(File.open(path))
        break
      end
    end
    show_error('Error: Unable to locate config file.') unless (@conf != nil)
    
    prep_connection
    
  end # initialize()
  
  def run
    
    show_error() unless (@opts.options.container != "")
    
    # Run appropriate action
    case @opts.options.action
    when 'push'
      if @opts.options.pipe_data
        push_piped_data
      else
        push_files
      end
    when 'pull'
      pull_files()
    when 'delete'
      delete_files
    else
      show_error()
    end
    
  end # run()
  
  private
  
  def prep_connection
    # Establish connection
    show_verbose "Establishing connection...", false
    @cf = CloudFiles::Connection.new(@conf["username"], @conf["api_key"]);
    show_verbose " done."
    
    # Special option for Slicehost customers in DFW datacenter
    if @opts.options.local_net
      @cf.storagehost = 'snet-storage.clouddrive.com'
    end
  end # prep_connection()
    
  def prep_container(create_container = true)
    # Check for the container. If it doesn't exist, create it if allowed
    if !@cf.container_exists?(@opts.options.container) && !create_container
      show_error("Error: Container '#{@opts.options.container}' does not exist.")
    else
      show_verbose "Container '#{@opts.options.container}' does not exist. Creating it...", false
      @cf.create_container(@opts.options.container)
      show_verbose " done."
    end
    
    @container = @cf.container(@opts.options.container)
  end # prep_cnnection()
  
  def push_piped_data
    prep_container
    
    puts "Warning: 5GB maximum filesize"
    object = @container.create_object(@opts.options.remote_path, true)
    object.write("STDIN")
  end # push_piped_data()
  
  def push_files
    prep_container
    
    path = @opts.options.local_path
  
    if FileTest::file?(path)
      Dir.chdir(File::dirname(path))
      glob_options = File.join(File::basename(path))
    elsif @opts.options.recursive
      Dir.chdir(path)
      glob_options = File.join("**", "*")
    else
      Dir.chdir(path)
      glob_options = File.join("*")
    end
    files = Dir.glob(glob_options)
    
    # Upload file(s)
    files.each do |file|  
      file = file.sub(/\.\//, '')
      if file == "" || file[0,1] == "." || FileTest.directory?(file)
        next 
      end
      
      show_verbose "Uploading #{file}...", false
      
      if @opts.options.remote_path.to_s == ''
        remote_path = file
      else
        remote_path = File.join(@opts.options.remote_path, file)
      end
        
      object = @container.create_object(remote_path, true)
      object.load_from_filename(file)
      
      show_verbose " done."
    end # files.each
    
  end # push_files()
  
  def pull_files()
    prep_container(false)
    
    file = false
    unless @opts.options.remote_path.to_s == ''
      if @container.object_exists?(@opts.options.remote_path)
        if @container.object(@opts.options.remote_path).content_type != "application/directory" && @opts.options.recursive
          puts "Warning: This is a file so the recursive option is meaningless."
          file = true
        end
      end
    end
    
    # Get array of objects to process
    if file
      objects = ["#{@container.object(@opts.options.remote_path)}"]
    elsif recursively
      # Use prefix instead of path so that "subdirectories" are included
      objects = @container.objects(:prefix => @opts.options.remote_path)
    else
      objects = @container.objects(:path => @opts.options.remote_path)
    end
    
    # Process objects
    counter = 1
    show_verbose "There are #{objects.count} objects to process."
    objects.each do |object|
      next unless (object.content_type != "application/directory")
      
      info = File.split(object.name)
      if info[0] == '.' || file
        filepath = @opts.options.local_path
      else
        filepath = File.join(@opts.options.local_path, info[0])
      end
      
      show_verbose "Pulling object (#{counter}/#{objects.count}) #{@object.name}...", false
      if file
        filename = info[1]
      else
        File.makedirs filepath
        filename = File.join(filepath, info[1])
      end
      
      object.save_to_filename(filename)
      show_verbose " done"
      counter += 1
    end
  end # pull_files()
  
  def delete_files
    
    # TODO: Implement delete_files
    # We have to do a bit of fancy footwork to make directories work
    puts "Oops! Deleting remote files hasn't been implemented yet. Help me out and submit a patch :-)"
    
  end # delete_files()
  
  
  # Helper methdos below
  
  # Shows given message if verbose output is turned on
  def show_verbose(message, line_break = true)
    unless !@opts.options.verbose
      if line_break
        puts message
      else
        print message
      end
      $stdout.flush
    end
  end # show_verbose()
  
  # Show error message, banner and exit
  def show_error(message = '')
    puts message
    puts @opts.banner
    exit
  end # show_error()
  
end # class CFBackup