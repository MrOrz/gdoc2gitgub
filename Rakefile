desc "Deploy to heroku, along with json config files"
task :deploy do
  sh "git checkout -b _deploy"

  sh "git add -f initial_tokens.json" unless Dir['initial_tokens.json'].empty?
  sh "git add -f client_secrets.json" unless Dir['client_secrets.json'].empty?
  sh "git commit -m \"From: #{`git log -n 1 --pretty=format:'%h - %s'`}\""

  sh "git push --force heroku _deploy:master"

  sh "git checkout -"
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