Pod::Spec.new do |s|
  s.name         = "ASQLite3"
  s.version      = "0.1.3"
  s.summary      = "ASQLite3 is an advanced extension for SQLite3 framework."
  s.description  = "ASQLite3 is an advanced extension for SQLite3 framework. Description."
  s.homepage     = "https://github.com/ihormyroniuk/ASQLite3"
  s.license      = "MIT"
  s.author       = { "Ihor Myroniuk" => "ihormyroniuk@gmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/ihormyroniuk/ASQLite3.git", :tag => "0.1.3" }
  s.source_files = "ASQLite3/**/*.{swift}"
  s.swift_version = "4.2"
end
