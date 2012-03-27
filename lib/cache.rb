class Inkit
  class Cache
    def initialize(secret)
      @secret = secret
      @cache_dir = './.ink-cache'
      Dir.mkdir @cache_dir unless Dir.exists? @cache_dir
      @cached_at = {}
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
      File.stat(filename(name)).mtime.rfc2822
    end
    def cached?(name)
      File.exists? filename(name)
    end
    
    private
    
    def filename(name)
      @cache_dir+"/."+OpenSSL::HMAC::hexdigest("sha256",@secret,name.to_s)
    end
  end
end
