Pod::Spec.new do |s|
  s.name         = "XTable"
  s.version      = "5.0.0"
  s.summary      = "Declaritive Tables"
  s.description  = <<-DESC
                   Create table layouts declaritively.
                   DESC
  s.homepage     = "https://github.com/BradHilton/Table"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Brad Hilton" => "brad@skyvive.com" }
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/BradHilton/Table.git", :tag => s.version }
  s.source_files  = "Table", "Table/**/*.{h,m,swift}"
  s.swift_version = '5.0'
  
  s.dependency 'Yoga', '1.6.0'
  s.dependency 'DeviceKit', '1.3.2'
end
