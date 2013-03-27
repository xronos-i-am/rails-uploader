# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uploader/version"

Gem::Specification.new do |s|
  s.name = "glebtv-rails-uploader"
  s.version = Uploader::VERSION.dup
  s.platform = Gem::Platform::RUBY 
  s.summary = "Rails file upload implementation with jQuery-File-Upload"
  s.description = "Rails HTML5 FileUpload helpers"
  s.authors = ["GlebTv"]
  s.email = "glebtv@gmail.com"
  s.rubyforge_project = "rails-uploader"
  s.homepage = "https://github.com/glebtv/rails-uploader"
  
  s.files = Dir["{app,lib,config,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["{spec}/**/*"]
  s.extra_rdoc_files = ["README.md"]
  s.require_paths = ["lib"]
  
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "carrierwave"
  s.add_development_dependency "rails", "3.2.13"
  s.add_development_dependency "mini_magick"
  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "rspec-rails", "~> 2.12.1"
  s.add_development_dependency "factory_girl_rails", "~> 3.2.0"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "fuubar"
end
