require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'cloudfiles'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cfbackup'

class Test::Unit::TestCase  
end
