# Unless otherwise noted, all files are released under the MIT license, 
# exceptions contain licensing information in them.
# 
#   Copyright (C) 2009 Jon Stacey
# 
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'lib/cloudfiles'
require 'OptCFBackup'
require 'yaml'

class CFBackup
  
  def initialize(args)
    @opts = OptCFBackup.new(args)

    unless (FileTest.exists?(@opts.options.config))
      showError('Error: Unable to locate config file')
    end
      
    @conf = YAML::load(File.open(self.opts.options.config))
  end # initialize()
  
  def run
    
    if @opts.options.path == "" || @opts.options.container == ""
      showError()
    end

    prepContainer
    
    if @opts.options.restore
      runRestore
    else
      runBackup
    end
    
  end # run()
  
  private
  
  def prepContainer
    
    # Establish connection
    showVerbose "Establishing connection...", false
    @cf = CloudFiles::Connection.new(@conf["username"], @conf["api_key"]);
    showVerbose " done."
    
    # Special option for Slicehost customers in DFW datacenter
    if @opts.options.slicehost
      self.cf.storagehost = 'snet-storage.clouddrive.com'
    end
    
    # Check for the container. If it doesn't exist, create it.
    unless @cf.container_exists?(@opts.options.container)
      showVerbose "Conainer '#{@opts.options.container}' does not exist. Creating it...", false
      @cf.create_container(@opts.options.container)
      showVerbose " done."
    end
    
    @container = @cf.container(@opts.options.container)
    
  end # prepConnection()
  
  def runBackup
    
    path = @opts.options.path
  
    if FileTest::file?(path)
      Dir.chdir(File::dirname(path))
      globOptions = File.join(File::basename(path))
    elsif recursive
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
    
  end # runRestore()
  
  # Shows given message if verbose output is turned on
  def showVerbose(message, lineBreak = true)
    
    unless !@opts.options.verbose
      if lineBreak
        puts message
      else
        print message
      end
    end
    
  end # showVerbose()
  
  # Show error message, banner and exit
  def showError(message = '')
    puts message
    puts @opts.banner
    exit
  end # showError()
  
end # class CFBackup

# Let's get the ball rolling
backup = CFBackup.new(ARGV)
backup::run