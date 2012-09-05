require 'idzebra'
require 'fileutils'

describe "IdZebra" do
  
  before :each do
    FileUtils.mkdir_p('tmp/zebra')
  end
  
  after :each do
    FileUtils.rm_rf('tmp/zebra')
  end
  
  it "should be able to start and stop" do
    extend IdZebra::Native
    zebra_service = zebra_start('spec/config/zebra.cfg')
    zebra_handle = zebra_open(zebra_service, nil)
    zebra_init(zebra_handle)
    zebra_clean(zebra_handle)
    zebra_compact(zebra_handle)
    zebra_commit(zebra_handle)
    zebra_close(zebra_handle)
    zebra_stop(zebra_service)
  end
  
end
