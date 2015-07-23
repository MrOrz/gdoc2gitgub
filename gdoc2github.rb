require 'json'
require './utils'
require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'


client_secret_options = JSON.parse(File.read('client_secrets.json'))

# http://www.rubydoc.info/github/google/google-api-ruby-client/Google%2FAPIClient%2FClientSecrets%3Ainitialize
if false
  # Get tokens from Redis
  client_secret_options['installed'].merge! {} #TODO: Some data from redis...
else
  # No tokens found, fetch from initial tokens
  client_secret_options['installed'].merge! hash_to_auth_options!(JSON.parse(File.read('initial_tokens.json')))
end

client_secrets = Google::APIClient::ClientSecrets.new client_secret_options

authorizaiton = client_secrets.to_authorization
authorizaiton.update!(
  :scope => 'https://www.googleapis.com/auth/drive.metadata.readonly',
  :redirect_uri => 'urn:ietf:wg:oauth:2.0:oob'
)

if authorizaiton.expired?
  authorizaiton.fetch_access_token!
  puts authorization_to_hash(authorizaiton) #TODO: save to redis
end

drive = Google::Apis::DriveV2::DriveService.new
drive.authorization = authorizaiton
files = drive.list_files

files.items.each do |file|
  puts file.title
end