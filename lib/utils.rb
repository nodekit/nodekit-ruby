class Hash
  def to_query
    map{|k,v| "#{::CGI.escape(k.to_s)}=#{::CGI.escape(v)}"}.join("&")
  end
end

class String
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end
end
