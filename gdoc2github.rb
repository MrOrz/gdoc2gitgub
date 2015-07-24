require 'json'
require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'open-uri'
require 'cgi'
require 'htmlbeautifier'
require './lib/utils'
require './lib/repository'
require './lib/storage'
require 'yaml'

# require 'pry'

FILE_ID = '1D_TfV5udsWesnD2RFQ5D2VXrbuPG6hOxW1bhqjPKaFg'

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
  Storage.google_credential = credential

  authorization.update! hash_to_auth_options!(credential) # This mutates `credential' too
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
puts "Getting revisions for file #{FILE_ID}..."

drive = Google::Apis::DriveV2::DriveService.new
drive.authorization = authorization
result = drive.list_revisions FILE_ID, fields: 'items(id, lastModifyingUser, modifiedDate)'
latest_revision = Storage.latest_revision
new_revs = result.items.delete_if {|item| item.id.to_i <= latest_revision}

#
# 2. Git operations
#
if new_revs.empty?
  puts "No new revisions found."

else
  puts "#{new_revs.size} new revisions found."

  Repository.init

  new_revs.each do |revision|
    puts "Processing revision ##{revision.id}"

    hashed_name = bubble_digest revision.last_modifying_user.display_name
    hashed_email = bubble_digest revision.last_modifying_user.email_address
    author_date = revision.modified_date

    coder = HTMLEntities.new
    unescaped_html = coder.decode open("https://docs.google.com/feeds/download/documents/export/Export?id=#{FILE_ID}&revision=#{revision.id}&exportFormat=html").read
    Repository.writeFile 'index.html', HtmlBeautifier.beautify(unescaped_html)
    Repository.writeFile 'index.yaml', parse_hacktabl(unescaped_html).to_yaml
    Repository.writeFile 'index.txt', open("https://docs.google.com/feeds/download/documents/export/Export?id=#{FILE_ID}&revision=#{revision.id}&exportFormat=txt").read

    Repository.commit hashed_name, hashed_email, author_date
  end

  puts "Pushing..."
  Repository.push
  Storage.latest_revision = new_revs[-1].id

  puts "Done :)"
end

