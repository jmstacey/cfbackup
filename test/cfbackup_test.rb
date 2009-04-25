require 'test_helper'

class CfbackupTest < Test::Unit::TestCase
  # Usage: cfbackup.rb --action push|pull|delete options --container CONTAINER
  
  # TODO: Mock STDIN to test piping data
  # context "A push using piped data" do
  #   setup do
  #     mock_ARGV = ['--action', 'push', '--pipe_data', '--container', 'test:data.txt', '--config_file', './cfconfig.yml']
  #     @backup = CFBackup.new(mock_ARGV)
  #   end
  #   
  #   should "return true when piped data successfully sent" do
  #     assert @backup.run
  #   end
  # end # context "A push using piped data"
  
  context "A recursive push" do
    setup do
      mock_ARGV = ['--action', 'push', '-r', '--container', 'test', '--local_path', 'test/data', '--config_file', 'cfconfig.yml']
      @backup = CFBackup.new(mock_ARGV)
    end
    
    should "return true when files successfully sent" do
      assert @backup.run
    end
  end # context "A recursive push"
  
  # context "A recursive pull" do
  #   setup do
  #     mock_ARGV = {""}
  #     @backup = CFBackup.new(mock_ARGV)
  #   end
  #   
  #   should "return true when files succesfully downloaded" do
  #     assert @backup.run
  #   end
  # end
  # 
  # context "A recursive deletion" do
  #   setup do
  #     mock_ARGV = {""}
  #     @backup = CFBackup.new(mock_ARGV)
  #   end
  #   
  #   should "should return true when files existed and were deleted" do
  #     assert @backup.run
  #   end
  # end # context "A recurisve deletion"
  # 
  
  
end
