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

  app.deployment_target = "7.0"
  #app.sdk_version = "8.3"
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]

  app.version = "#{VERSION}"
  app.short_version = VERSION

  app.identifier = 'io.knoxjeffrey.github'

  app.development do
    puts "Loading development configs"
    app.codesign_certificate = 'iPhone Developer: Jeffrey Knox'
    app.provisioning_profile = '../../Certificates/DevelopmentProvisioningProfile.mobileprovision'
    app.entitlements['get-task-allow'] = true
  end

  app.release do
    puts "Loading release configs"
    app.codesign_certificate = 'iPhone Distribution: Jeffrey Knox (B2EADBZBS6)'
    app.provisioning_profile = 'profiles/ProCon.mobileprovision'
    app.entitlements['beta-reports-active'] = true
    app.entitlements['get-task-allow'] = false
  end
  
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.frameworks << 'QuartzCore'

  app.icons = Dir["#{File.dirname(__FILE__)}/resources/icon*.png"].map do |path|
    path.split('/').last
  end

end
task :"build:simulator" => :"schema:build"
