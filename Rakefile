# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require File.join(File.dirname(__FILE__), 'version.rb')

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProCon'
  app.version = "#{VERSION}"
  app.short_version = VERSION
  app.identifier = 'io.knoxjeffrey.github'
  #app.codesign_certificate = 'iPhone Developer: Jeffrey Knox'
  #app.provisioning_profile = '../../Certificates/DevelopmentProvisioningProfile.mobileprovision'
  app.codesign_certificate = 'iPhone Distribution: Jeffrey Knox (B2EADBZBS6)'
  app.provisioning_profile = 'profiles/ProCon.mobileprovision'
  app.entitlements['get-task-allow'] = false
  app.interface_orientations = [:portrait]
  
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.frameworks << 'QuartzCore'

  app.device_family = [:iphone]

  app.deployment_target = "7.0"
  #app.sdk_version = "8.3"

end
task :"build:simulator" => :"schema:build"
