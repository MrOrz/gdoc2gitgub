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