require 'spec/spec_helper'

describe IcingaRest::ServiceCheck do
  before(:each) do
    @check = IcingaRest::ServiceCheck.new(
      :host         => 'my.icinga.host',
      :authkey      => 'itsasekrit',
      :filter       => [
        {:service_name => 'Foobar', :state => :critical}
      ]
    )
  end

  context "filtering" do

    it "filters on hostname like whatever*" do
      @check.filter << {:host_name => 'foobar*'} 
      request = mock IcingaRest::Request, :get => '{"success":"true"}'
      request_params = {
        :host         => 'my.icinga.host',
        :target       => 'service',
        :filter       => 'AND(((SERVICE_NAME|=|Foobar);AND(SERVICE_CURRENT_STATE|=|2));AND(HOST_NAME|like|foobar*))',
        :count_column => 'SERVICE_ID',
        :authkey      => 'itsasekrit',
        :output       => 'json'
      }
      IcingaRest::Request.should_receive(:new).with(request_params).and_return(request)
      @check.count
    end

    it "filters on hostname is whatever" do
      @check.filter << {:host_name => 'foobar'} 
      request = mock IcingaRest::Request, :get => '{"success":"true"}'
      request_params = {
        :host         => 'my.icinga.host',
        :target       => 'service',
        :filter       => 'AND(((SERVICE_NAME|=|Foobar);AND(SERVICE_CURRENT_STATE|=|2));AND(HOST_NAME|=|foobar))',
        :count_column => 'SERVICE_ID',
        :authkey      => 'itsasekrit',
        :output       => 'json'
      }
      IcingaRest::Request.should_receive(:new).with(request_params).and_return(request)
      @check.count
    end

    it "creates a request" do
      request = mock IcingaRest::Request, :get => '{"success":"true"}'
      request_params = {
        :host         => 'my.icinga.host',
        :target       => 'service',
        :filter       => 'AND(((SERVICE_NAME|=|Foobar);AND(SERVICE_CURRENT_STATE|=|2)))',
        :count_column => 'SERVICE_ID',
        :authkey      => 'itsasekrit',
        :output       => 'json'
      }
      IcingaRest::Request.should_receive(:new).with(request_params).and_return(request)
      @check.count
    end
  end

  context "counting" do
    it "throws an exception if request unsuccessful" do
      json = '{"success":"false"}'
      request = mock IcingaRest::Request, :get => json
      IcingaRest::Request.stub!(:new).and_return(request)
      expect {
        @check.count
      }.to raise_error("API call failed")
    end

    it "parses json response" do
      json = '{"result":[{"SERVICE_ID":"16649","SERVICE_OBJECT_ID":"4546","SERVICE_IS_ACTIVE":"1","SERVICE_INSTANCE_ID":"1","SERVICE_NAME":"Foobar","SERVICE_DISPLAY_NAME":"Foobar","SERVICE_OUTPUT":"CRITICAL: Foobar is broken","SERVICE_PERFDATA":"in_service=0"},{"SERVICE_ID":"14083","SERVICE_OBJECT_ID":"1972","SERVICE_IS_ACTIVE":"1","SERVICE_INSTANCE_ID":"1","SERVICE_NAME":"Foobar","SERVICE_DISPLAY_NAME":"Foobar","SERVICE_OUTPUT":"CRITICAL: Foobar is broken","SERVICE_PERFDATA":"in_service=0"},{"SERVICE_ID":"12688","SERVICE_OBJECT_ID":"548","SERVICE_IS_ACTIVE":"1","SERVICE_INSTANCE_ID":"1","SERVICE_NAME":"Foobar","SERVICE_DISPLAY_NAME":"Foobar","SERVICE_OUTPUT":"CHECK_NRPE: Socket timeout after 10 seconds.","SERVICE_PERFDATA":""},{"SERVICE_ID":"13138","SERVICE_OBJECT_ID":"1013","SERVICE_IS_ACTIVE":"1","SERVICE_INSTANCE_ID":"1","SERVICE_NAME":"Foobar","SERVICE_DISPLAY_NAME":"Foobar","SERVICE_OUTPUT":"CHECK_NRPE: Socket timeout after 10 seconds.","SERVICE_PERFDATA":""},{"SERVICE_ID":"12763","SERVICE_OBJECT_ID":"638","SERVICE_IS_ACTIVE":"1","SERVICE_INSTANCE_ID":"1","SERVICE_NAME":"Foobar","SERVICE_DISPLAY_NAME":"Foobar","SERVICE_OUTPUT":"CRITICAL: Foobar is broken","SERVICE_PERFDATA":"in_service=0"}],"success":"true","total":5}'
      request = mock IcingaRest::Request, :get => json
      IcingaRest::Request.stub!(:new).and_return(request)

      @check.count.should == 5
    end

    it "sends request" do
      request = mock IcingaRest::Request
      IcingaRest::Request.stub!(:new).and_return(request)
      request.should_receive(:get).and_return('{"success":"true","total":5}')
      @check.count
    end

  end
end
