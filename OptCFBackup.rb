require 'optparse'
require 'ostruct'

class OptCFBackup
  
  # Options structure
  attr_reader :options
  
  # Ussage message
  attr_reader :banner

  # Initializes object with command line arguments passed
  def initialize(args)
    
    @banner = "Usage: cfbackup.rb [options] --local_path PATH --container CONTAINER"
    
    @options = OpenStruct.new
    self.options.show_ver  = false
    self.options.recursive = false
    self.options.restore   = false
    self.options.unmetered = false
    self.options.path      = ''
    self.options.container = ''
    self.options.config    = 'cfconfig.yml'
    self.options.verbose   = false;
    
    opts = OptionParser.new do |opts|
      opts.banner = self.banner
      
      opts.on("-r", "--recursive", "Traverse local path recursivley") do |recursive|
        self.options.recursive = recursive
      end
      
      opts.on("-v", "--verbose", "Run verbosely") do |verbose|
        self.options.verbose = verbose
      end
      
      opts.on("--local_path LOCAL_PATH", "Local path or file") do |path|
        self.options.path = path
      end
      
      opts.on("--container CONTAINER", "Cloud Files container name") do |name|
        self.options.container = name
      end
      
      opts.on("--restore", "Restore files to local path") do |restore|
        self.options.restore = restore
      end
      
      opts.on("--version", "Show current version") do |version|
        self.options.show_ver = version
      end
      
      opts.on("--config_file PATH", "Use specified config file, rather than the default") do |config|
        self.options.config = config
      end
      
      opts.on("--slicehost", "Use unmetered connection in DFW1 (only applicable to Slicehost or Mosso Cloud Server customers)") do |unmetered|
        self.options.unmetered = unmetered
      end
      
    end
    
    opts.parse!(args)
    
  end # parse()
  
end # class OptCFBackup