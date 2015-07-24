require 'redis'
require 'json'

class Storage
  uri = URI.parse ENV["REDIS_URL"] || "redis://127.0.0.1:6379"
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  def self.google_credential
    str = REDIS.get 'google_credential'
    return str.nil? ? nil : JSON.parse(str)
  end

  def self.google_credential= credential_hash
    REDIS.set 'google_credential', credential_hash.to_json
  end

  def self.latest_revision
    REDIS.get('latest_revision').to_i
  end

  def self.latest_revision= revision
    REDIS.set 'latest_revision', revision
  end
end