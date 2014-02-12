# Class to count services in a given state, optionally filtered by host name, either as
# a pattern ('foo*', or '*foo*'), or as an exact match ('foobar')
class IcingaRest::ServiceCheck
  attr_accessor :host,    # The Icinga server
                :authkey, # API key
                :filter,  # List of tuples
                :user,    # user for http basic auth
                :password # password for http basic auth

  SERVICE_STATES = {
    :ok       => 0,
    :warn     => 1,
    :critical => 2
  }

  # Define a service check to be carried out.
  #
  # Currently, only counting services in a given state is possible,
  # where the service name and state are provided as literals, with
  # optional filtering on host name, either as an exact match or 
  # with wildcards in the host name.
  #
  # Arguments:
  # * :host - The Icinga host. The REST API must be available at the default location
  #   http://[host]/icinga-web/web/api/
  # * :authkey - Your API key to access the REST API
  # * :filter - a list of tuples to filter the count
  #   e.g.
  #     [ {:host_name => 'web*'}, {:service_name => 'Load', :state => :critical} ]
  #
  #   The :host_name and :service_name should match hosts and services you have configured
  #   in Icinga (otherwise your count will always be zero).
  #
  #   :state should be one of :ok, :warn, :critical
  #
  # Example:
  #
  #     check = IcingaRest::ServiceCheck.new(
  #       :host    => 'my.icinga.host',
  #       :authkey => 'mysecretapikey',
  #       :filter  => [
  #         {:host_name    => 'web*'},
  #         {:service_name => 'Load', :state => :critical}
  #       ]
  #     )
  #
  #     puts check.count
  #
  def initialize(params)
    @host     = params[:host]
    @authkey  = params[:authkey]
    @filter   = params[:filter]
    @user     = params[:user]
    @password = params[:password]
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
      :output       => 'json',
      :user         => user,
      :password     => password
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
