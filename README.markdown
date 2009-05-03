CFBackup
=========

CFBackup is a small ruby program that transfers files or directories from the local machine to a Cloud Files container. It is meant to serve as a useful tool for automated backups.

Features
-----------

* Push (backup) a single file or directory (uses pseudo directories)
* Pull (restore) a single file or directory
* Delete (rotate) remote objects
* Pipe data straight to container
* Free transfers over local Rackspace network for Slicehost/Cloud Server 
  customers in DFW1 datacenter
	
Requirements
--------------

* ruby-cloudfiles

Notes: 
* If you install CFBackup as a gem, all of the dependencies _should_ automatically be installed for you.
* Ubuntu Users: The Ubuntu rubygems package will installs executables outside your normal PATH. You will
  need to update it or create a symlink to access cfbackup from anywhere. See the wiki for more information.reating a symlink.

Install
-----------

* gem sources -a http://gems.github.com
* sudo gem install jmstacey-cfbackup

Configuration
-----------

A sample configuration file named cfconfig.yml should have be placed in /etc if installed as a gem.
CFBackup will look in the following places (in order) for the configuration file named cfconfig.yml:

* Hidden in home directory (~/.cfbackup.yml)
* Non-hidden in present working directory (./cfbackup.yml)
* In etc (/etc/cfbackup.yml)

The configuration file can be overridden at any time with the --config_file option

Configuration
-----------

    Usage: cfbackup.rb --action push|pull|delete options --container CONTAINER
            --action ACTION              Action to perform: push, pull, or delete.
            --pipe_data                  Pipe data from another application and stream it to Cloud Files
        -r, --recursive                  Traverse local path recursivley
        -v, --verbose                    Run verbosely
            --local_path LOCAL_PATH      Local path or file
            --container CONTAINER        Cloud Files container name
            --version                    Show current version
            --config_file PATH           Use specified config file, rather than the default
            --local_net                  Use unmetered connection in DFW1 (only applicable to Slicehost or Mosso Cloud Server customers)
            
The wiki has usage examples and some sample automation scripts can be found in the example_scripts directory.

Copyright
------------

Copyright (c) 2009 Jon Stacey. See LICENSE for details.