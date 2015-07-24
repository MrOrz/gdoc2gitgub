REPO_URL = "https://#{ENV['GH_TOKEN']}@#{ENV['GH_REF']}"
BRANCH = 'gh-pages'
REPO_LOCATION = './repo'

class Repository
  def self.init
    `rm -rf #{REPO_LOCATION}`
    `git clone "#{REPO_URL}" --depth 1 -b #{BRANCH} #{REPO_LOCATION}`
  end

  def self.writeFile pathname, content
    Dir.chdir(REPO_LOCATION) do
      File.open(pathname, 'w') { |f| f.write content }
    end
  end

  def self.commit name, email, date
    Dir.chdir(REPO_LOCATION) do
      `git config user.name #{name}`
      `git config user.email #{email}`
      `git add .`
      `git commit -m "#{name}(#{email}) modified at #{date.to_s}" --date #{date.to_s}`
    end
  end

  def self.push
    Dir.chdir(REPO_LOCATION) do
      `git push #{REPO_URL} #{BRANCH}`
    end
  end
end
