require '../lib/inkit'

def test(type,code)
  case type
    when 'haml'
      code =~ /%[A-Za-z0-9]*/
    when 'html'
      code =~ /<[A-Za-z0-9]*>/
    else
      false
  end
end

Given /^I have (.*) secret and (.*) token$/ do |secret, token|
  @ink = Inkit.new({:secret => secret, :token => token})
  @code = []
end

When /^I render the (.*) view in:/ do |view,table|
  table.raw.each_with_index do |a,i|
    @code.push @ink.method(a[0].downcase).call view
  end
end


When /^I try to get (.*) view as (.*)$/ do |view,type|
  begin
    @response = @ink.method(type.downcase).call view
  rescue Exception => e
    @response = e.message
  end
end

When /^I try to get (.*) view when not modified$/ do |view|
  data = {:view => view.to_s, :type => 'haml'}
  data[:digest] = @ink.digest(data)
  data[:token] = @ink.token
  uri = URI("http://inkit.org/api/document?"+data.to_query)
  req = ::Net::HTTP::Get.new uri.request_uri
  req['If-Modified-Since'] = Time.now.rfc2822
  res = ::Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  }
  @response = res.code
end


Then /^I shoud get a (\d+) response$/ do |arg1|
  @response.should == arg1
end


Then /^I shoud get the code in:$/ do |table|
  table.raw.each_with_index do |a,i|
    test(a[0].downcase,@code[i]).should be_true
  end
end

