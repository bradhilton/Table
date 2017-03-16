Pod::Spec.new do |s|
  s.name         = "Table"
  s.version      = "0.0.3"
  s.summary      = "Declaritive Tables"
  s.description  = <<-DESC
                   Create table layouts declaritively.
                   DESC
  s.homepage     = "https://github.com/BradHilton/Table"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Brad Hilton" => "brad@skyvive.com" }
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/BradHilton/Table.git", :tag => "0.0.3" }
  s.source_files  = "Table", "Table/**/*.{h,m,swift}"
end
