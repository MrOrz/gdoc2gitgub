require 'json'
require './utils'
require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

#
# 1. Fetch revision from Google Drive
#

# Create Google oauth authentication
# http://www.rubydoc.info/github/google/google-api-ruby-client/Google%2FAPIClient%2FClientSecrets%3Ainitialize
#
client_secrets = Google::APIClient::ClientSecrets.new JSON.parse(File.read('client_secrets.json'))
authorization = client_secrets.to_authorization

# Populate auth data
#
auth_options = {}
if false
  # Get tokens from Redis
  authorization.update! {} #TODO: Some data from redis...
else
  # No tokens found, fetch from initial tokens
  authorization.update! hash_to_auth_options!(JSON.parse(File.read('initial_tokens.json')))
end

# Update access token if needed
#
if authorization.expired?
  puts "Access token expired, updating..."
  authorization.fetch_access_token!

  puts "Access token updated."
  puts authorization_to_hash(authorization) #TODO: save to redis
end

# Fetch revision Data
#
drive = Google::Apis::DriveV2::DriveService.new
drive.authorization = authorization
files = drive.list_files

files.items.each do |file|
  puts file.title
end

#
# 2. Git operations
#
