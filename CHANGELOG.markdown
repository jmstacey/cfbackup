CFBackup ChangeLog
==================

0.8.0 2010-??-??
-----------------
* Code documented
* Gem deployed on gemcutter
Work sponsored by Shaun Brazier
* Cloudfiles API dependency updated to 1.4.4
* Basic exception handling and retry mechanisms
* New --max_retries option
* New --ignore_errors option
  * File push errors can now be ignored
* New --error_log option
  * File push errors can be written to a log for later processing

0.7.1 2009-05-19
-----------------
* Version bump and re-release of 0.6.1 because the published gem by GitHub was marked as 0.7.0.

0.6.1 2009-05-19
-----------------
* Use official Rackspace CloudFiles API from GitHub
* Corrected case issue on case-sensitive filesystems

0.6.0 2009-05-03
-----------------
* Added example_scripts to RDoc.
* gem creates cfconfig.yml in /etc for reference
* CFBackup looks in multiple places for config file
  * Hidden directory in $HOME ($HOME/.cfconfig.yml)
  * Non-hidden in current directory (./cfconfig.yml)
  * In /etc/cfconfig.yml
* Refactoring and new usage with --action push|pull|delete
* Pulling files implemented
* Deleting files implemented
* Initial unit tests completed

0.5.0 2009-04-18
-----------------

* Conversion to a Ruby Gem
* cfbackup put in bin so that it can be called from anywhere
* Looks in a few standard locations for the config file
* Unit test framework prepped
* Cloud Files API has been moved to a separate repository and made available as a gem
* Most doc files converted to markdown

0.0.4 2009-04-11
-----------------

* Pipe data straight to container
* Specify remote path or file name

0.0.3 2009-04-08
-------------------

* Initial release to public
