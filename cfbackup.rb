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

require 'lib/cloudfiles'
require 'OptCFBackup'
require 'yaml'

class CFBackup
  
  def initialize(args)
    @opts = OptCFBackup.new(args)

    # Special case if the version is requested
    if @opts.options.show_ver
      showError('CFBackup v0.3 [027b2a5c]')
    end
    
    unless (FileTest.exists?(@opts.options.config))
      showError('Error: Unable to locate config file')
    end
      
    @conf = YAML::load(File.open(@opts.options.config))
  end # initialize()
  
  def run
    
    showError() unless (@opts.options.container != "")
    
    if @opts.options.pipe_data
      prepContainer
      run_piped_data
    elsif @opts.options.path != ""
      prepContainer
      
      if @opts.options.restore
        runRestore
      else
        runBackup
      end
    else
      showError()
    end
    
  end # run()
  
  private
  
  def prepContainer
    
    # Establish connection
    showVerbose "Establishing connection...", false
    @cf = CloudFiles::Connection.new(@conf["username"], @conf["api_key"]);
    showVerbose " done."
    
    # Special option for Slicehost customers in DFW datacenter
    if @opts.options.local_net
      @cf.storagehost = 'snet-storage.clouddrive.com'
    end
    
    # Check for the container. If it doesn't exist, create it.
    unless @cf.container_exists?(@opts.options.container)
      showVerbose "Conainer '#{@opts.options.container}' does not exist. Creating it...", false
      @cf.create_container(@opts.options.container)
      showVerbose " done."
    end
    
    @container = @cf.container(@opts.options.container)
    
  end # prepConnection()
  
  def run_piped_data
    object = @container.create_object('test.txt', true)
    object.write($stdin)
  end
  
  def runBackup
    
    path = @opts.options.path
  
    if FileTest::file?(path)
      Dir.chdir(File::dirname(path))
      globOptions = File.join(File::basename(path))
    elsif @opts.options.recursive
      Dir.chdir(path)
      globOptions = File.join("**", "*")
    else
      Dir.chdir(path)
      globOptions = File.join("*")
    end
    files = Dir.glob(globOptions)
    
    # Upload file(s)
    files.each do |file|  
      file = file.sub(/\.\//, '')
      if file == "" || file[0,1] == "." || FileTest.directory?(file)
        next 
      end
      
      showVerbose "Uploading #{file}...", false
      object = @container.create_object(file, true)
      object.load_from_filename(file)
      showVerbose " done."
    end # files.each
    
  end # runBackup()
  
  def runRestore
    
    # TODO: Implement runRestore
    # We have to do a bit of fancy footwork to make directories work
    puts "Oops! Restore hasn't been implemented yet. Help me out and submit a patch :-)"
    
  end # runRestore()
  
  # Shows given message if verbose output is turned on
  def showVerbose(message, lineBreak = true)
    
    unless !@opts.options.verbose
      if lineBreak
        puts message
      else
        print message
      end
      
      $stdout.flush
    end
    
  end # showVerbose()
  
  # Show error message, banner and exit
  def showError(message = '')
    puts message
    puts @opts.banner
    exit
  end # showError()
  
  def parse_container_path(container)
    # Split based on :
  end # parse_container_path()
  
end # class CFBackup

# Let's get the ball rolling
backup = CFBackup.new(ARGV)
backup::run