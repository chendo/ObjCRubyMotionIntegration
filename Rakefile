# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ObjCRubyMotionIntegration-Ruby'
  app.files = Dir.glob('ObjCRubyMotionIntegration/**/*.rb')
  app.pods do
    File.readlines('Podfile').select { |line| line =~ /^pod /}.each do |pod_line|
      eval pod_line
    end
  end
end
