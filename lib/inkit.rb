require "net/http"
require "uri"
require 'cgi'
require 'mustache'
require 'time'
require 'json'

load File.dirname(__FILE__)+"/utils.rb"
load File.dirname(__FILE__)+"/cache.rb"

module INK
  TYPE_HTML = {'Content-Type' => 'text/html'}
  class INK::RackAdapter
    def initialize(app, options)
      @app = app if app.respond_to?(:call)
      @ink = Inkit.new options
      @views = @ink.documents.map { |view| "/#{view['name']}" }
    end                

    def call(env)
      @status, @headers, @response = @app.call(env)
      locals = JSON.parse @response[0]
      request = Rack::Request.new(env)
      view = request.path_info
      filename = request.path_info.split("/").last
      a = filename.split(".")
      name = a[0]
      ext = a.last
      if ext == 'css'
        puts request.referer.gsub "http://"+request.host_with_port+"/", ""
      elsif @views.include? view
        view = view[1..view.length]
        return [200,TYPE_HTML,[@ink.html(view,{:locals => locals})]]
      end
      return @app ? @app.call(env) : [404,TYPE_HTML,['Not found!']]
    end      
  end
end

class Inkit

  attr_reader :token, :secret
  attr_accessor :endpoint

  # Constructor
  def initialize(options)
    raise 'Please provide your secret key!' unless options[:secret]
    @secret = options[:secret].to_s
    @token = options[:token].to_s
    @endpoint = 'api.inkit.org'
    @cache = Cache.new(@secret)
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
  
  def css(view, options = {})
    render(view, options, 'css')
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
    ret.gsub /\s*$/, ''
    Mustache.render(ret, options[:locals])
  end
  
  def pull(view,type = 'haml')
    v = view+"."+type
    data = {}
    data[:modified_since ] = @cache.cached_at(v) if @cache.cached?(v)
    res = request("document/"+v, data )
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
    data[:timestamp] = DateTime.now.iso8601
    data[:digest] = digest(data)
    data[:token] = @token
    uri = URI("http://#{@endpoint}/#{path.to_s}?"+data.to_query)
    req = ::Net::HTTP::Get.new uri.request_uri
    res = ::Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
  end
end

