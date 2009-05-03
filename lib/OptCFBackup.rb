require 'optparse'
require 'ostruct'

class OptCFBackup
  
  # Options structure
  attr_reader :options
  
  # Ussage message
  attr_reader :banner

  # Initializes object with command line arguments passed
  def initialize(args)
    
    @banner = "Usage: cfbackup.rb --action push|pull|delete options --container CONTAINER"
    
    @options = OpenStruct.new
    self.options.config       = ["#{ENV['HOME']}/.cfconfig.yml", './cfconfig.yml', '/etc/cfconfig.yml']
    self.options.action       = ''
    self.options.pipe_data    = false
    self.options.show_ver     = false
    self.options.recursive    = false
    self.options.local_net    = false
    self.options.container    = ''
    self.options.local_path   = ''
    self.options.remote_path  = ''
    self.options.verbose      = false;
    
    opts = OptionParser.new do |opts|
      opts.banner = self.banner
      
      opts.on("--action ACTION", "Action to perform: push, pull, or delete.") do |action|
        self.options.action = action
      end
      
      opts.on("--pipe_data", "Pipe data from another application and stream it to Cloud Files") do |pipe|
        self.options.pipe_data = pipe
      end
      
      opts.on("-r", "--recursive", "Traverse local path recursivley") do |recursive|
        self.options.recursive = recursive
      end
      
      opts.on("-v", "--verbose", "Run verbosely") do |verbose|
        self.options.verbose = verbose
      end
      
      opts.on("--local_path LOCAL_PATH", "Local path or file") do |local_path|
        self.options.local_path = local_path
      end
      
      opts.on("--container CONTAINER", "Cloud Files container name") do |name|
        self.options.container, self.options.remote_path = name.split(":", 2)
        clean_remote_path unless (self.options.remote_path.nil?) 
      end
      
      opts.on("--version", "Show current version") do |version|
        self.options.show_ver = version
      end
      
      opts.on("--config_file PATH", "Use specified config file, rather than the default") do |config|
        self.options.config = Array.new()
        self.options.config << config
      end
      
      opts.on("--local_net", "Use unmetered connection in DFW1 (only applicable to Slicehost or Mosso Cloud Server customers)") do |local_net|
        self.options.local_net = local_net
      end
      
    end
    
    opts.parse!(args)
    
  end # initialize()
  
  private
  
  def clean_remote_path
    if self.options.remote_path[0,1] == "/"
      self.options.remote_path.slice!(0)
    end
    # Follwoig won't work for piped data. Might result in "text.txt/"
    # self.options.remote_path = self.options.remote_path + "/" unless (self.options.remote_path[-1,1] == "/")
  end
  
end # class OptCFBackup