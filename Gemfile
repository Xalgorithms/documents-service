source 'https://rubygems.org'

ruby '2.3.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'countries'
gem 'rails', '~> 5.0.3'
gem 'puma', '~> 3.0'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'mongoid', '~> 6.1.0'
gem 'uuid'

# ours
gem 'xa-messages', github: 'Xalgorithms/xa-messages'
gem 'xa-ubl', github: 'Xalgorithms/xa-ubl'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'radish', github: 'karfai/radish'
#gem 'radish', path: '../../../../projects/radish'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fuubar'
  gem "rspec-rails"
  gem "mongoid-rspec"
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'pry-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
