# Class to count services in a given state, optionally filtered by host name, either as
# a pattern ('foo*', or '*foo*'), or as an exact match ('foobar')
class IcingaRest::FilterCheck
  attr_accessor :host,    # The Icinga server
                :authkey, # API key
                :filter,  # List of tuples
                :target   # target host|service

  SERVICE_STATES = {
    :ok       => 0,
    :warn     => 1,
    :critical => 2
  }

  def initialize(params)
    @host    = params[:host]
    @authkey = params[:authkey]
    @target  = params[:target]
    @filter  = params[:filter]
  end

  def count
    json = request.get
    result = JSON.load json
    if result['success'] == 'true'
      result['total']
    else
      raise "API call failed"
    end
  end

  private

  def request
    IcingaRest::Request.new(
      :host         => host,
      :target       => target,
      :filter       => filter,
      :count_column => 'SERVICE_ID',
      :authkey      => authkey,
      :output       => 'json'
    )
  end
end
