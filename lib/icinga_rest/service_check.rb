# Class to count services in a given state,
# optionally filtered by host name, either as
# a pattern ('foo*', or '*foo*'), or as an 
# exact match ('foobar')
class IcingaRest::ServiceCheck
  attr_accessor :host,    # The Icinga server
                :authkey, # API key
                :filter   # List of tuples

  SERVICE_STATES = {
    :ok       => 0,
    :warn     => 1,
    :critical => 2
  }

  def initialize(params)
    @host    = params[:host]
    @authkey = params[:authkey]
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
      :target       => 'service',
      :filter       => filters,
      :count_column => 'SERVICE_ID',
      :authkey      => authkey,
      :output       => 'json'
    )
  end

  def filters
    clauses = filter.inject([]) {|list, tuple| list << filter_clause(tuple)}
    "AND(%s)" % clauses.map {|c| "(#{c})"}.join(';AND')
  end

  def filter_clause(tuple)
    if tuple[:host_name]
      host_clause tuple
    elsif tuple[:service_name]
      service_clause tuple
    else
      raise "Bad filter clause #{tuple.inspect}"
    end
  end


  # {:service_name => 'Foobar', :state => :critical} => '(SERVICE_NAME|=|Foobar);AND(SERVICE_CURRENT_STATE|=|2)'
  def service_clause(tuple)
    name = tuple[:service_name]
    state = SERVICE_STATES[tuple[:state]]
    "(SERVICE_NAME|=|%s);AND(SERVICE_CURRENT_STATE|=|%d)" % [name, state]
  end

  # {:host_name => '*foobar*'} => 'HOST_NAME|like|*foobar*'
  # {:host_name => 'foobar'}   => 'HOST_NAME|=|foobar'
  def host_clause(tuple)
    name = tuple[:host_name]
    operator = name.index('*').nil? ? '=' : 'like'
    ['HOST_NAME', operator, name].join('|')
  end

end
