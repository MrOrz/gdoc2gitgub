require 'json'
require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require './utils'
require './storage'

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
credential = Storage.google_credential
if credential.nil?
  # No tokens found, fetch from initial tokens and store it
  credential = JSON.parse(File.read('initial_tokens.json'))
  authorization.update! hash_to_auth_options!(credential)
  Storage.google_credential = credential
else
  # Get tokens from storage
  authorization.update! hash_to_auth_options!(credential)
end

# Update access token if needed
#
if authorization.expired?
  puts "Access token expired, updating..."
  authorization.fetch_access_token!
  Storage.google_credential = authorization_to_hash(authorization)
  puts "Access token updated."
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
