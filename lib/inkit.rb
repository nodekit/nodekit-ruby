require "net/http"
require "uri"
require 'cgi'
require 'mustache'
require 'time'

load File.dirname(__FILE__)+"/utils.rb"
load File.dirname(__FILE__)+"/cache.rb"

class Inkit

  attr_reader :token, :secret, :endpoint

  # Constructor
  def initialize(options)
    raise 'Please provide your secret key!' unless options[:secret]
    @secret = options[:secret].to_s
    @token = options[:token].to_s
    @endpoint = 'localhost:9292'
    @cache = Cache.new(@secret)
    @nocache = !options[:cache] or true
  end
  
  def documents
    res = request(:documents)
    if res.is_a?(::Net::HTTPSuccess)
      return JSON.parse res.body
    end
    raise res.code
  end
  
  def html(view, options = {})
    render(view, options)
  end
  
  def json(view, options = {})
    render(view, options, 'json')
  end
  
  def jade(view, options = {})
    render(view, options, 'jade')
  end
  
  def coffeekup(view, options = {})
    render(view, options, 'coffeekup')
  end
  
  def haml(view, options = {})
    render(view, options, 'haml')
  end
  
  def render(view, options = {}, type = 'html')
    ret = self.pull(view,type)
    if options[:layout]
      layout = render(options[:layout], {}, type)
      indent = 0
      if layout =~ /( *)\{{3}yield\}{3}/
        indent = $1.length
      end
      ret = "\n#{ret}"
      ret = Mustache.render(layout,:yield => Mustache.render(ret.indent(indent)))
    end
    ret.gsub /\s*$/, ''
  end
  
  def pull(view,type = 'haml')
    v = view+"."+type
    data = {:view => view.to_s, :type => type}
    data[:cached_at ] = @cache.cached_at(v) if @cache.cached?(v) and not @nocache
    res = request(:document, data )
    if res.is_a?(::Net::HTTPSuccess)
      @cache[v] = res.body
      return @cache[v]
    end
    if res.is_a?(::Net::HTTPNotModified)
      return @cache[v]
    end
    raise res.code
  end
  
  def digest(hash)
    OpenSSL::HMAC::hexdigest("sha256", @secret, hash.to_query)
  end
  
  def request(path, data = {})
    data[:timestamp] = DateTime.now.rfc2822
    data[:digest] = digest(data)
    data[:token] = @token
    uri = URI("http://#{@endpoint}/api/#{path.to_s}?"+data.to_query)
    req = ::Net::HTTP::Get.new uri.request_uri
    res = ::Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
  end
end

