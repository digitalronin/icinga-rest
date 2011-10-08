require 'spec/spec_helper'

describe IcingaRest::Request do
  before(:each) do
    @request = IcingaRest::Request.new(
      :host         => 'my.icinga.host',
      :target       => 'service',
      :filter       => 'AND(SERVICE_NAME|=|Foobar;AND(SERVICE_CURRENT_STATE|!=|0))',
      :count_column => 'SERVICE_ID',
      :authkey      => 'itsasekrit',
      :output       => 'json'
    )
  end

  context "requesting" do
    it "composes a URI" do
      url = 'http://my.icinga.host/icinga-web/web/api/service/filter[AND(SERVICE_NAME|=|Foobar;AND(SERVICE_CURRENT_STATE|!=|0))]/countColumn=SERVICE_ID/authkey=itsasekrit/json'
      @request.to_url.should == url
    end
  end
end
