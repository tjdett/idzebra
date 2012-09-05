require 'idzebra'
require 'fileutils'

describe "IdZebra" do
  
  it "should respond to :API" do
    IdZebra.respond_to?(:API)
  end
  
  it "should respond to :log_level=" do
    IdZebra.respond_to?(:log_level=)
  end
    
  it "should allow creation and population of a repository " do
    file_data = File.open('spec/fixtures/oaipmh_test_1.xml') {|f| f.read}
    begin
      IdZebra::log_level = :error
      IdZebra::API('spec/config/zebra.cfg') do |repo|
        repo.init
        repo.add_record(file_data)
        repo.commit
        repo.delete_record(file_data)
        repo.commit
      end
    ensure
      IdZebra::log_level = :default
    end
  end
  
  describe "Repository" do
    
    subject do
      IdZebra::Repository.new(nil)
    end
    
    before :each do
      FileUtils.mkdir_p('tmp/zebra')
    end
    
    after :each do
      FileUtils.rm_rf('tmp/zebra')
    end
    
    it { should respond_to(:init, :clean, :commit, :compact)}
    
    it { should respond_to(:add_record, :update_record, :delete_record)}
    
  end
  
  describe "Native" do
    
    before :each do
      FileUtils.mkdir_p('tmp/zebra')
    end
    
    after :each do
      FileUtils.rm_rf('tmp/zebra')
    end
    
    it "should be have access to native methods" do
      extend IdZebra::Native
      begin
        IdZebra::log_level = :error
        zebra_service = zebra_start('spec/config/zebra.cfg')
        zebra_handle = zebra_open(zebra_service, nil)
        zebra_init(zebra_handle)
        zebra_clean(zebra_handle)
        
        file_data = File.open('spec/fixtures/oaipmh_test_1.xml') {|f| f.read}
        
        # Add some records
        zebra_add_record(zebra_handle, file_data, 0)
        zebra_commit(zebra_handle)
        
        # Test compaction of records
        zebra_compact(zebra_handle)
        
        # Delete some records
        zebra_update_record(zebra_handle, 
          :action_delete, nil, 0, nil, nil, file_data, 0)
        zebra_commit(zebra_handle)
        
        # Close
        zebra_close(zebra_handle)
        zebra_stop(zebra_service)
      ensure
        IdZebra::log_level = :default
      end
    end
  end
  
end
