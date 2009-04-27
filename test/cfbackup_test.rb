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
  
  $test_dir = "test/tmp"
  
  context "A recursive push" do
    setup do
      mock_ARGV = ['--action', 'push', '-r', '--local_path', 'test/data', '--container', 'test', '--config_file', 'cfconfig.yml']
      @backup = CFBackup.new(mock_ARGV)
    end
    
    should "return true when files successfully sent" do
      assert @backup.run
    end
  end # context "A recursive push"
  
  context "A single file pull" do
    file     = 'data.txt'
    filepath = File.join($test_dir, file)
    
    setup do
      mock_ARGV = ['--action', 'pull', '--container', "test:#{file}", '--local_path', "#{filepath}", '--config_file', 'cfconfig.yml']
      @backup = CFBackup.new(mock_ARGV)
    end

    should "return true when file succesfully pulled" do
      assert @backup.run
    end
    
    # I don't know why this doesn't work. It's like File is caching results
    # and not updating until the applicaiton exists. Overcoming by
    # asserting the file deletion during teardown at the loss of should
    #
    # should "create the test/tmp/#{file} existing" do      
    #   assert File.exist?(filepath)
    # end
    
    teardown do
      assert File.delete(filepath)
    end
  end # context "A single file pull"
  
  context "A recursive pull" do    
    setup do
      mock_ARGV = ['--action', 'pull', '--container', "test", '--local_path', "test/tmp", '--config_file', 'cfconfig.yml']
      @backup = CFBackup.new(mock_ARGV)
    end
    
    should "return true when all files pulled" do
      assert @backup.run
    end
    
    teardown do
      system "rm -rf test/tmp/*"
      # I didn't feel save with $test_dir + '/*'
      # Disaster waiting to happen. rm_rf is already bad enough.
    end
  end # context "A single file pull"
  
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
