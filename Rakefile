desc "Deploy to heroku, along with json config files"
task :deploy do
  has_initial_token = !Dir['initial_tokens.json'].empty?
  has_client_secret = !Dir['client_secrets.json'].empty?

  sh "git checkout -b _deploy"

  sh "git add -f initial_tokens.json" if has_initial_token
  sh "git add -f client_secrets.json" if has_client_secret
  sh "git commit -m \"From: #{`git log -n 1 --pretty=format:'%h - %s'`}\""

  sh "git push --force heroku _deploy:master"

  sh "git checkout -"

  if has_initial_token
    sh "git checkout _deploy initial_tokens.json"
    sh "git reset HEAD initial_tokens.json"
  end
  if has_client_secret
    sh "git checkout _deploy client_secrets.json"
    sh "git reset HEAD client_secrets.json"
  end

  sh "git branch -D _deploy"
end

desc "Generate initial_tokens.json"
task :init do
  ruby 'get_initial_tokens.rb'
end

desc "Run gdoc2github"
task :run do
  ruby 'gdoc2github.rb'
end

task :default => [:run]