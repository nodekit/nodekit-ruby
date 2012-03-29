require "net/http"
require "uri"
require 'cgi'
require 'mustache'
require 'time'

load File.dirname(__FILE__)+"/utils.rb"
load File.dirname(__FILE__)+"/cache.rb"

class Inkit

  attr_reader :token, :secret

  # Constructor
  def initialize(options)
    raise 'Please provide your secret key!' unless options[:secret]
    @secret = options[:secret].to_s
    @token = options[:token].to_s
    @cache = Cache.new(@secret)
  end
  
  def digest(hash)
    OpenSSL::HMAC::hexdigest("sha256", @secret, hash.to_query)
  end
  
  def pull(view,type = 'haml')
    data = {:view => view.to_s, :type => type, :timestamp => Time.now.rfc2822}
    data[:digest] = digest(data)
    data[:token] = @token
    uri = URI("http://inkit.org/api/document?"+data.to_query)
    req = ::Net::HTTP::Get.new uri.request_uri
    if @cache.cached? view+"."+type
      req['If-Modified-Since'] = @cache.cached_at view+"."+type
    end
    res = ::Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
    if res.is_a?(::Net::HTTPSuccess)
      @cache[view+"."+type] = res.body
      return @cache[view+"."+type]
    end
    if res.is_a?(::Net::HTTPNotModified)
      return @cache[view+"."+type]
    end
    raise res.code
  end
  
  def html(view, options = {})
    render(view, options)
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
end

