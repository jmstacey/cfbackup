CFBackup
=========

CFBackup is a small ruby program that transfers files or directories from the local machine to a Cloud Files container. It is meant to serve as a useful tool for automated backups.

Features
-----------

* Backup a single file or directory (recursion uses pseudo directories)
* Pipe data straight to container
* Free transfers over local Rackspace network for Slicehost/Cloud Server 
  customers in DFW1 datacenter
	
Requirements
--------------

* ruby-cloudfiles

Note: If you install CFBackup as a gem, all of the dependencies _should_ automatically be installed for you.

Install
-----------

* gem sources -a http://gems.github.com
* sudo gem install jmstacey-cfbackup

Copyright
------------

Copyright (c) 2009 Jon Stacey. See LICENSE for details.