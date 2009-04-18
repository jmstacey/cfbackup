# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name          = 'CFBackup'
  s.version       = '0.0.4'
  
  s.summary       = 'Backup utility script for Mosso Cloud Files'
  s.description   = 'A simple ruby program intended to serve as a useful tool for automated backups to Mosso Cloud Files.'
  
  s.files         = Dir['**']
  s.require_paths = ['ruby-cloudfiles/lib']
  
  s.has_rdoc      = true
  
  s.author        = 'Jon Stacey'
  s.email         = 'jon@jonsview.com'
  s.homepage      = 'http://jonsview.com/projects/cfbackup'
end