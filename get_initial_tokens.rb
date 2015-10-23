require './lib/utils'
require 'json'
require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

client_secrets = Google::APIClient::ClientSecrets.load
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => client_secrets.client_id,
  :client_secret => client_secrets.client_secret,
  :scope => 'https://www.googleapis.com/auth/drive.metadata.readonly',
  :port => 5000)

hash = authorization_to_hash flow.authorize(nil, {})

File.open('initial_tokens.json', 'w') {|f| f.write( hash.to_json) }
