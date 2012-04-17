class Inkit
  class Cache
  
    def initialize(secret)
      @secret = secret
      @cache_dir = './.ink-cache'
      Dir.mkdir @cache_dir unless Dir.exists? @cache_dir
    end
    
    def []=(name,data)
      File.open( filename(name), "w+") do |io|
        io.write data
      end
    end
    
    def [](name)
      File.read filename(name)
    end
    
    def cached_at(name)
      File.stat(filename(name)).mtime.iso8601
    end
    
    def cached?(name)
      File.exists? filename(name)
    end
    
    private
    
    def filename(name)
      a = File.extname name
      b = File.basename name, a
      @cache_dir+"/."+OpenSSL::HMAC::hexdigest("sha256",@secret,b.to_s)+a
    end
  end
end
