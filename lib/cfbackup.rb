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
require 'optcfbackup'
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
    if !@cf.container_exists?(@opts.options.container)
      if create_container
        show_verbose "Container '#{@opts.options.container}' does not exist. Creating it...", false
        @cf.create_container(@opts.options.container)
        show_verbose " done."
      else
        show_error("Error: Container '#{@opts.options.container}' does not exist.")
      end
    end
    
    @container = @cf.container(@opts.options.container)
  end # prep_cnnection()
  
  def push_piped_data
    prep_container
    
    puts "Note: Rackspace enforces a 5GB maximum filesize."
    object = @container.create_object(@opts.options.remote_path, true)
    object.write
  end # push_piped_data()
  
  def push_files
    prep_container
    
    path = @opts.options.local_path
    pwd  = Dir.getwd # Save current directory so we can come back
    
    if FileTest::file?(path)
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
    counter = 1
    show_verbose "There are #{files.length} files to process."
    files.each do |file|
      file = file.sub(/\.\//, '')
      if file == "" || file[0,1] == "." || FileTest.directory?(file)
        show_verbose "(#{counter}/#{files.length}) Skipping #{file}"
        counter += 1
        next 
      end
      
      show_verbose "(#{counter}/#{files.length}) Pushing file #{file}...", false
      
      if @opts.options.remote_path.to_s == ''
        remote_path = file
      else
        remote_path = File.join(@opts.options.remote_path, file)
      end
        
      object = @container.create_object(remote_path, true)
      object.load_from_filename(file)
      
      show_verbose " done."
      counter += 1
    end # files.each
    
    Dir.chdir(pwd) # Go back to original directory
    
  end # push_files()
  
  def pull_files
    prep_container(false)
    
    file    = object_file?
    objects = get_objects_array
    
    # Process objects
    counter = 1
    show_verbose "There are #{objects.length} objects to process."
    objects.each do |object_name|
      object = @container.object(object_name)
      if object.content_type == "application/directory"
        show_verbose "(#{counter}/#{objects.length}) Pseudo directory #{object.name}"
        counter += 1
        next
      end
      
      path_info = File.split(@opts.options.local_path.to_s)
      file_info = File.split(object.name.to_s)
      
      if file # Dealing with a single file pull
        if @opts.options.local_path.to_s == ''
          filepath = file_info[1].to_s # Use current directory and original name
        else
          if File.exist?(@opts.options.local_path.to_s)
            # The file exists, so we will overwrite it
            filepath = File.join(@opts.options.local_path.to_s)
          else
            # If the file doesn't exist, a new name may have been given.
            # Test the path.
            if File.exist?(path_info[0])
              # A new name was given with a valid path
              filepath = File.join(path_info[0], path_info[1])
            else
              # The given path is not valid
              show_error("cfbackup: #{file_info[0]}: No such file or directory.")
            end
          end
        end
      else # Dealing with a multi-object pull
        if @opts.options.local_path.to_s == ''
          filepath = object.name.to_s # Use current directory with object name
          dir_path = file_info[0]
        else
          if File.directory?(@opts.options.local_path.to_s)
            filepath = File.join(@opts.options.local_path.to_s, object.name.to_s)
            dir_path = File.join(@opts.options.local_path, file_info[0])
          else
            # We can't copy a directory to a file...
            show_error("cfbackup: #{@container.name}:#{@opts.options.remote_path.to_s}/ is a directory (not copied).")
          end
        end
        File.makedirs(dir_path) # Create subdirectories as needed
      end
      
      show_verbose "(#{counter}/#{objects.length}) Pulling object #{object.name}...", false
      object.save_to_filename(filepath)
      show_verbose " done"
      counter += 1
    end
  end # pull_files()
  
  def delete_files
    prep_container(false)
    
    if object_file?
      show_verbose "Deleting object #{@opts.options.remote_path.to_s}"
      @container.delete_object(@opts.options.remote_path.to_s)
    else
      if !@opts.options.recursive
        show_error("Error: #{@opts.options.remote_path} is a directory but the the recursive option was not specified. Doing nothing.")
      else
        objects = get_objects_array
        
        # Process objects
        counter = 1
        show_verbose "There are #{objects.length} objects to process."
        objects.each do |object_name|
          show_verbose "(#{counter}/#{objects.length}) Deleting object #{object_name}...", false
          @container.delete_object(object_name)
          show_verbose " done"
          counter += 1
        end
      end
    end
    
  end # delete_files()
  
  
  # Helper methods below
  
  def object_file?
    
    file = false
    unless @opts.options.remote_path.to_s == ''
      if @container.object_exists?(@opts.options.remote_path)
        if @container.object(@opts.options.remote_path).content_type != "application/directory"
          file = true
          if @opts.options.recursive
            puts "Warning: This is a file so the recursive option is meaningless."
          end
        end
      else
        show_error("The object #{@opts.options.remote_path} does not exist")
      end
    end
    
    return file
  end
  
  def get_objects_array
    
    file = object_file?
    
    # Get array of objects to process
    objects = Array.new
    if file
      objects << @opts.options.remote_path.to_s
    elsif @opts.options.recursive
      # Use prefix instead of path so that "subdirectories" are included
      objects = @container.objects(:prefix => @opts.options.remote_path)
    else
      objects = @container.objects(:path => @opts.options.remote_path)
    end
    
    return objects
  end
  
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