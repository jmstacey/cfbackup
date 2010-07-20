# Contains CFBackup unit tests.

require 'test_helper'

# todo: finish bug 17 tests
# Assert everything by creating a Cloudfiles object and verifying file
# integrity

# CFBackup test class
class CfbackupTest < Test::Unit::TestCase
  TEST_DIR = 'test/tmp' # Test directory
  
  # Test --error_log option
  context "A backup with the --error_log option enabled" do
    setup do
      mock_ARGV = ['--action', 'push', '--local_path', 'test/data/data.txt', '--container', 'test', '--config_file', 'test/cfconfig.yml', '-v', '--error_log', 'error.log']
      backup = CFBackup.new(mock_ARGV)
    end
    
    should "result in a log file being created" do
      assert_equal true, File.exists?('error.log')
    end
    
    teardown do
      File.delete('error.log')
    end
  end
  
  # Test connections
  context "A connection" do
    
    context "that fails with a ConnectionException and the default number of retries" do
      should "should be retried 3 times and then exit" do
        CloudFiles::Connection.expects(:new).times(4).raises(ConnectionException)
        # We expect 4 calls (1 initial + 3 retries)
  
        assert_raises(SystemExit) do
          mock_ARGV = ['--action', 'push', '--local_path', 'test/data/data.txt', '--container', 'test', '--config_file', 'test/cfconfig.yml', '-v']
          CFBackup.new(mock_ARGV)
        end
      end
    end # context "that fails with a ConnectionException..."
    
  end
  
  # Test uploading files.
  # First a single file is uploaded, then a recursive directory
  # push is performed.
  context "A backup" do
    
    context "with a single file push" do
      setup do
        mock_ARGV = ['--action', 'push', '--local_path', 'test/data/data.txt', '--container', 'test', '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when file sucessfully sent" do
        assert @backup.run
      end
    end
    
    context "with a single file push not in CWD [Bug #17]" do
      setup do
        File.copy('test/data/cwd_bug_17/bug_17.txt', '/tmp/cfbackup_bug_17.txt')
        assert File.exist?('/tmp/cfbackup_bug_17.txt')
        
        mock_ARGV = ['--action', 'push', '--local_path', '/tmp/cfbackup_bug_17.txt', '--container', 'test', '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end

      should "return true when file sucessfully sent" do
        assert @backup.run
      end
      
      # should "result in file being pushed" do
      #   # Assert file uploaded
      # end
      
    end
    
    context "with a recursive directory push" do
      setup do
        mock_ARGV = ['--action', 'push', '-r', '--local_path', 'test/data', '--container', 'test', '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when all files/directories successfully sent" do
        assert @backup.run
      end
    end
  
  end 
  
  # Test restoring files.
  # First attempts pulling a single file, then attempts a recursive
  # directory pull. Cleans up afterwards.
  context "A restore" do
    
    context "with a single file pull" do
      file     = 'data.txt'
      filepath = File.join(TEST_DIR, file)
  
      setup do
        mock_ARGV = ['--action', 'pull', '--container', "test:#{file}", '--local_path', "#{filepath}", '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
  
      should "return true and cause the file to exist" do
        assert @backup.run
        assert File.exist?(filepath)
      end
  
      teardown do
        assert File.delete(filepath)
      end
    end
    
    context "with a single file pull not in CWD [Bug #17]" do
      file     = 'folder_1/folder_3/file1.txt';
      filepath = File.join(TEST_DIR, File::basename(file))
      
      setup do
        mock_ARGV = ['--action', 'pull', '--container', "test:#{file}", '--local_path', "#{filepath}", '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true and cause the file to exist" do
        assert @backup.run
        assert File.exist?(filepath)
      end
      
      teardown do
        assert File.delete(filepath)
      end
      
    end
    
    context "with a recursive pull" do    
      setup do
        mock_ARGV = ['--action', 'pull', '--container', "test", '--local_path', "test/tmp", '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when all files pulled" do
        assert @backup.run
      end
      
      # Todo compare directories
      
      teardown do
        system "rm -rf test/tmp/*"
        # I didn't feel safe with TEST_DIR + '/*'
        # Disaster waiting to happen. rm -rf is already bad enough.
      end
    end # context "A recursive pull"
    
  end
  
  # Test deleting remote objects.
  # First test deleting a single remote object representing a file,
  # then delete a pseudo directory recursively.
  context "A deletion" do
    
    context "of a single file" do
      setup do
        mock_ARGV = ['--action', 'delete', '--container', "test:folder_1/file1.txt", '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when file deleted" do
        assert @backup.run
      end
    end
    
    context "of a pseudo directory" do
      setup do
        mock_ARGV = ['--action', 'delete', '-r', '--container', "test:folder_2", '--config_file', 'test/cfconfig.yml', '-v']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when directory deleted" do
        assert @backup.run
      end
    end
    
  end # context "A deletion"
  
end
