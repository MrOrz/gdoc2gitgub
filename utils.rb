require 'digest'
require 'digest/bubblebabble'
require 'v8'
require 'json'
require 'cgi'
require 'htmlentities'

@ctx = V8::Context.new
@ctx.eval(File.open('./vendor/hacktabl-parser.js', 'r').read)

def authorization_to_hash(authorization)
  hash = {}
  %w'
    scope
    access_token
    client_id
    client_secret
    expires_in
    refresh_token'.each do |var|
    hash[var] = authorization.instance_variable_get("@#{var}")
  end

  hash['redirect_uri'] = authorization.redirect_uri.to_s
  hash['token_credential_uri'] = authorization.token_credential_uri.to_s
  hash['authorization_uri'] = authorization.authorization_uri.to_s
  hash['issued_at'] = authorization.issued_at.to_i

  hash
end

def hash_to_auth_options!(hsh)
  hsh['issued_at'] = Time.at hsh['issued_at']
  hsh
end

def bubble_digest str
  bubble = Digest::SHA256.bubblebabble(str).split('-')
  return "#{bubble[2]}-#{bubble[-2]}"
end

def parse_hacktabl unescaped_html_str
  @ctx['__result'] = @ctx[:TableParser].call(unescaped_html_str)

  # Pass the data from v8 context to ruby using json string
  raw_data = JSON.parse @ctx.eval("JSON.stringify(__result)")

end