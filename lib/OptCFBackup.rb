require 'optparse'
require 'ostruct'

class OptCFBackup
  
  # Options structure
  attr_reader :options
  
  # Ussage message
  attr_reader :banner

  # Initializes object with command line arguments passed
  def initialize(args)
    
    @banner = "Usage: cfbackup.rb [options] --pipe_data|--local_path PATH --container CONTAINER"
    
    @options = OpenStruct.new
    self.options.config       = ['~/.cfconfig.yml', '/etc/cfconfig.yml', './cfconfig.yml']
    self.options.config       = ''
    self.options.pipe_data    = false
    self.options.show_ver     = false
    self.options.recursive    = false
    self.options.restore      = false
    self.options.local_net    = false
    self.options.container    = ''
    self.options.local_path   = ''
    self.options.remote_path  = ''
    self.options.verbose      = false;
    
    opts = OptionParser.new do |opts|
      opts.banner = self.banner
      
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
      
      opts.on("--restore", "Restore files to local path") do |restore|
        self.options.restore = restore
      end
      
      opts.on("--version", "Show current version") do |version|
        self.options.show_ver = version
      end
      
      opts.on("--config_file PATH", "Use specified config file, rather than the default") do |config|      
        self.options.config << config
      end
      
      opts.on("--local_net", "Use unmetered connection in DFW1 (only applicable to Slicehost or Mosso Cloud Server customers)") do |local_net|
        self.options.local_net = local_net
      end
      
    end
    
    opts.parse!(args)
    
  end # parse()
  
  private
  
  def clean_remote_path
    if self.options.remote_path[0,1] == "/"
      self.options.remote_path.slice!(0)
    end
    # Won't work for piped data. Might result in "text.txt/"
    # self.options.remote_path = self.options.remote_path + "/" unless (self.options.remote_path[-1,1] == "/")
  end
  
end # class OptCFBackup