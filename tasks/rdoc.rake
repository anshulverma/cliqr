# encoding: utf-8

begin
  require 'rdoc/task'

  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = '.doc/rdoc'
    rdoc.title = "cliqr #{Cliqr::VERSION}"
    rdoc.main = 'README.md'
    rdoc.rdoc_files.include('README.md', 'LICENSE.txt', 'CHANGELOG.md', 'lib/**/*.rb')
  end
  CLEAN.include('.doc')
rescue LoadError
  # do nothing
end
