# Wrapper to simplify constructing the http GET request
# to access the Icinga REST API
class IcingaRest::Request
  attr_accessor :host,         # The Icinga server
                :authkey,      # API key
                :target,       # host|service
                :filter,       # filter string to use. e.g. 'AND(SERVICE_NAME|=|Foobar;AND(SERVICE_CURRENT_STATE|!=|0))'
                :count_column, # count this column to produce the total
                :output        # json|xml

  WGET = '/usr/bin/wget'

  def initialize(params)
    @host         = params[:host]
    @target       = params[:target]
    @filter       = params[:filter]
    @count_column = params[:count_column]
    @authkey      = params[:authkey]
    @output       = params[:output]
  end

  # It would be nicer to use Net::HTTP, or something, but the 
  # URLs required by the Icinga API are not well-formed, and 
  # the URI library, used by most of the ruby http libs, barfs.
  # So, we shell out to wget, which is more tolerant.
  # Fugly, but functional.
  def get
    `#{WGET} -q -O - '#{to_url}'`
  end

  def to_url
    "http://%s/icinga-web/web/api/%s/%s/authkey=%s/%s" % [host, target, url_options, authkey, output]
  end

  private

  # The optional components of the API request path
  def url_options
    [filter_url, count_column_url].compact.join('/')
  end

  def filter_url
    self.filter ? "filter[%s]" % filter : nil
  end

  def count_column_url
    self.count_column ? "countColumn=%s"% count_column : nil
  end

end
