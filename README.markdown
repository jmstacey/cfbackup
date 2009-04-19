CFBackup
=========

CFBackup is a small ruby program that transfers files or directories from the
local machine to a Cloud Files container. It is meant to serve as a useful tool
for automated backups.

Features
-----------

* Backup a single file or directory (recursion uses pseudo directories)
* Pipe data straight to container
* Free transfers over local Rackspace network for Slicehost/Cloud Server 
	customers in DFW1 datacenter
	
Requirements
--------------

TODO: Complete this area
* ruby-cloudfiles

Install
-----------
TODO: Complete this area

sudo gem install mime-types archive-tar-minitar nokogiri hoe rcov

git clone git://github.com/jmstacey/cfbackup.git cfbackup

Copyright
------------

Copyright (c) 2009 Jon Stacey. See LICENSE for details.