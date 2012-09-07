require 'idzebra'
require 'fileutils'

describe "IdZebra" do

  def mute_log_output
    begin
      IdZebra::log_level = :error
      yield
    ensure
      IdZebra::log_level = :default
    end
  end

  def run_server
    begin
      pid = fork do
        # Replace forked process with our server
        exec "zebrasrv -v none -f spec/config/yazserver.xml"
      end
      # Yield for block
      yield
    ensure
      # Send kill signal
      Process.kill "TERM", pid
      # Wait for termination, otherwise it will become a zombie process
      Process.wait pid
    end
  end

  def fetch_record_count
    # We do this with a unix socket so we don't have to worry about
    # tests failing if the port is in use.
    #
    # Code largely based on code samples by Jordan Sissel of semicomplete.com
    require 'net/http'
    sock = Net::HTTP.socket_type.new(Socket.unix("tmp/zebra.sock"))
    begin
      request_path = '?version=1.1&operation=searchRetrieve&query=rec.id%3E0'
      request = Net::HTTP::Get.new(request_path)
      request.exec(sock, "1.1", request_path)

      # Wait for and parse the http response.
      begin
        response = Net::HTTPResponse.read_new(sock)
      end while response.kind_of?(Net::HTTPContinue)
      response.reading_body(sock, request.response_body_permitted?) { }
      return 0 unless response.code.to_i == 200
      contents = response.body
      count_re = /<zs:numberOfRecords>(\d+)<\/zs:numberOfRecords>/
      contents =~ count_re ? $1.to_i : 0
    ensure
      sock.close
    end
  end

  it "should respond to :API" do
    IdZebra.should respond_to(:API)
  end

  it "be able to set logging levels" do
    IdZebra.log_level = :error
    IdZebra.log_level.should == :error
    IdZebra.log_level = :default
    IdZebra.log_level.should == :info
    # Set using numeric
    IdZebra.log_level = 0x2000
    IdZebra.log_level.should == :error
    IdZebra.log_level = 0x2001
    IdZebra.log_level.should == 0x2001
  end

  it "should allow creation and population of a repository " do
    file_data = File.open('spec/fixtures/oaipmh_test_1.xml') {|f| f.read}
    begin
      FileUtils.mkdir_p('tmp/zebra')
      mute_log_output do
        run_server do
          IdZebra::API('spec/config/zebra.cfg') do |repo|
            repo.init
            fetch_record_count.should == 0
            repo.add_record(file_data)
            fetch_record_count.should == 0
            repo.commit
            fetch_record_count.should == 100
            repo.delete_record(file_data)
            fetch_record_count.should == 100
            repo.commit
            fetch_record_count.should == 0
          end
        end
      end
    ensure
      IdZebra::log_level = :default
      FileUtils.rm_rf('tmp/zebra')
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
      mute_log_output do
        extend IdZebra::Native
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
      end
    end
  end

end
