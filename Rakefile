# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProCon'
  app.identifier = 'io.knoxjeffrey.github'
  app.codesign_certificate = 'iPhone Developer: Jeffrey Knox'
  app.provisioning_profile = '../../Certificates/DevelopmentProvisioningProfile.mobileprovision'
  
  app.interface_orientations = [:portrait]
  
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.frameworks << 'QuartzCore'
  
end
task :"build:simulator" => :"schema:build"
