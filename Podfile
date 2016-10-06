platform :osx, '10.10'

target 'Grif65Tests' do
  use_frameworks!
  pod 'Quick'
  pod 'Nimble'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
