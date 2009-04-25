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
      pull_files
    when 'delete'
      delete_files
    else
      show_error()
    end
    
  end # run()
  
  private
  
  def prep_container
    
    # Establish connection
    show_verbose "Establishing connection...", false
    @cf = CloudFiles::Connection.new(@conf["username"], @conf["api_key"]);
    show_verbose " done."
    
    # Special option for Slicehost customers in DFW datacenter
    if @opts.options.local_net
      @cf.storagehost = 'snet-storage.clouddrive.com'
    end
    
    # Check for the container. If it doesn't exist, create it.
    unless @cf.container_exists?(@opts.options.container)
      show_verbose "Conainer '#{@opts.options.container}' does not exist. Creating it...", false
      @cf.create_container(@opts.options.container)
      show_verbose " done."
    end
    
    @container = @cf.container(@opts.options.container)
    
  end # prepConnection()
  
  def push_piped_data
    
    prep_container
    
    puts "Warning: 5GB maximum filesize"
    object = @container.create_object(@opts.options.remote_path, true)
    object.write("STDIN")
  end
  
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
      object = @container.create_object(file, true)
      object.load_from_filename(file)
      show_verbose " done."
    end # files.each
    
  end # push_files()
  
  def pull_files
    
    # TODO: Implement pull_files
    # We have to do a bit of fancy footwork to make directories work
    puts "Oops! Pulling files hasn't been implemented yet. Help me out and submit a patch :-)"
    
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
  
  def parse_container_path(container)
    # Split based on :
  end # parse_container_path()
  
end # class CFBackup