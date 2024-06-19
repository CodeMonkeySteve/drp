require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
require 'rake/contrib/sshpublisher'

PROJECT_NAME = 'drp'
RUBYFORGE_USER = 'polypus'
RDOC_OPTIONS = ['--main','README','--include','examples/intro']

PKG_FILES = FileList[ 
  'CHANGES', 'AUTHORS', 'README', 'TODO', 'LICENSE',
  'Rakefile',
  'examples/intro/*',
  'examples/*.rb',
  'lib/**/*.rb',
  'test/**/*.rb'
].to_a

RDOC_FILES = FileList[
  'README', 
  'INTRO'
].to_a

TEST_SUITE_FILE_NAME = 'test/ts_drp.rb'

DRP_DESCRIPTION = %{
Directed Programming is a new generative programming technique developed by Christophe McKeon which is a generalisation of Grammatical Evolution (http://www.grammatical-evolution.org) allowing one not only to do GE, but also to do Genetic Programming (http://www.genetic-programming.org) in pure Ruby without explicitly generating a program string as output. DP even allows you to set up hybrids of GP and GE where part of a GE subtree is calculated using normal Ruby functions/operators/etc. via. GP. DRP is the first ever implementation of DP and is written in pure Ruby. 
}

spec = Gem::Specification.new do |s|

  s.name    = PROJECT_NAME
  s.version = `ruby -Ilib -e 'require "info"; puts DRP::Version'`.strip
  s.summary = 'genetic programming * grammatical evolution = directed (ruby) programming'
  s.platform = Gem::Platform::RUBY

  s.require_path = 'lib'
#  s.autorequire = PROJECT_NAME
  s.files = PKG_FILES

  s.rdoc_options = s.rdoc_options + RDOC_OPTIONS
  s.extra_rdoc_files = RDOC_FILES

  s.author = 'Christophe McKeon'
  s.email = 'polypus@yahoo.com'
  s.homepage = 'http://drp.rubyforge.org'
  s.rubyforge_project = PROJECT_NAME

  s.description = DRP_DESCRIPTION
      
  s.test_file = TEST_SUITE_FILE_NAME

end

task :default => [:package]

# creates :package and :gem tasks
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

# creates an :rdoc task
Rake::RDocTask.new do |rd|
  # rd.main = 'README' # this is set in options
  rd.title = PROJECT_NAME
  rd.rdoc_files = RDOC_FILES + FileList['lib/**/*.rb'].to_a
  rd.rdoc_dir = 'rdoc'
  rd.options += RDOC_OPTIONS
end

# creates an :rdoc task for :rubyforge_publish task
Rake::RDocTask.new(:rdoc_publish) do |rd|
  rd.title = PROJECT_NAME
  rd.rdoc_files = RDOC_FILES + FileList['lib/**/*.rb'].to_a
  rd.rdoc_dir = 'rubyforge_website/rdoc'
  rd.options += RDOC_OPTIONS
end

# creates a :test task
Rake::TestTask.new do |tt|
  tt.pattern = TEST_SUITE_FILE_NAME
  tt.verbose = true
#  tt.warning = true
end

task :rubyforge_publish => [:rdoc_publish] do
  # copies the contents of website, into the top level dir at rubyforge
  host = RUBYFORGE_USER + "@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PROJECT_NAME}"
  local_dir = "rubyforge_website"
  Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
  # this did not allow control over name of local dir
  # Rake::RubyForgePublisher.new(PROJECT_NAME, RUBYFORGE_USER).upload
end
