require 'test_helper'

class CfbackupTest < Test::Unit::TestCase
  TEST_DIR = 'test/tmp'
  
  context "A backup" do
    
    context "with a single file push" do
      setup do
        mock_ARGV = ['--action', 'push', '--local_path', 'test/data/data.txt', '--container', 'test', '--config_file', 'test/cfconfig.yml']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when file sucessfully sent" do
        assert @backup.run
      end
    end
    
    context "with a recursive directory push" do
      setup do
        mock_ARGV = ['--action', 'push', '-r', '--local_path', 'test/data', '--container', 'test', '--config_file', 'test/cfconfig.yml']
        @backup = CFBackup.new(mock_ARGV)
      end
      
      should "return true when all files/directories successfully sent" do
        assert @backup.run
      end
    end

  end 
  
  context "A restore" do
    
    context "with a single file pull" do
      file     = 'data.txt'
      filepath = File.join(TEST_DIR, file)

      setup do
        mock_ARGV = ['--action', 'pull', '--container', "test:#{file}", '--local_path', "#{filepath}", '--config_file', 'test/cfconfig.yml']
        @backup = CFBackup.new(mock_ARGV)
      end

      should "return true when file succesfully pulled" do
        assert @backup.run
      end

      # I don't know why this doesn't work. It's like File is caching results
      # and not updating until the applicaiton exists. Overcoming by
      # asserting the file deletion during teardown at the loss of shoulda
      #
      # should "result in test/tmp/#{file} existing" do      
      #   assert File.exist?(filepath)
      # end

      teardown do
        assert File.delete(filepath)
      end
    end
    
    context "A recursive pull" do    
      setup do
        mock_ARGV = ['--action', 'pull', '--container', "test", '--local_path', "test/tmp", '--config_file', 'test/cfconfig.yml']
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
  
  # context "A deletion" do
  #   
  #   context "of a single file" do
  #     setup do
  #       mock_ARGV = ['--action', 'delete', '--container', "test:data.txt", '--config_file', 'test/cfconfig.yml']
  #       @backup = CFBackup.new(mock_ARGV)
  #     end
  #     
  #     should "return true when file deleted" do
  #       assert @backup.run
  #     end
  #   end
  #   
  #   context "of a pseudo directory" do
  #     # Do stuff
  #   end
  #   
  # end
  
end
