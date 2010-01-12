# Handle option parsing for use in CFBackup.

require 'optparse'
require 'ostruct'

# Option parser class for CFBackup
class OptCFBackup
  
  attr_reader :options # Options structure
  attr_reader :banner  # Ussage message

  # Implementation of initialize
  #
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
    self.options.verbose      = false
    self.options.max_retries  = 3
    self.options.ignore_errors= false
    self.options.error_log    = "./cfbackup_error.log"
    
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
      
      opts.on("--max_retries", "Change the number of times to retry an operation before giving up.") do |config|
        self.options.max_retries = max_retries
      end
      
      opts.on("--ignore_errors", "Ignore file operation errors and continue processing other files. More information will be written to the error log.") do |ignore_errors|
        self.options.ignore_errors = ignore_errors
      end
      
      opts.on("--error_log", "Change the output location of the error file if the --skip_failures option is set") do |error_log|
        self.options.error_log = error_log
      end
      
    end
    
    opts.parse!(args) # Parse arguments
    
  end # initialize()
  
  private
  
  # Remove trailing slash from the remote path if present.
  def clean_remote_path
    if self.options.remote_path[0,1] == "/"
      self.options.remote_path.slice!(0)
    end
  end # clean_remote_path()
  
end # class OptCFBackup