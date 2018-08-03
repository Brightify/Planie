source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

# TODO Change branch to version once released.

def shared_pods
    pod 'Firebase', '~> 3.14.0', :subspecs => ['Auth', 'Crash', 'Database']
    pod 'SwiftDate', '~> 4.5.1'
    pod 'Fetcher', '~> 0.3.1'
    pod 'Fetcher/RxFetcher', '~> 0.3.1'
    pod 'DataMapper', '~> 0.1'
    pod 'Reactant', :git => 'https://github.com/Brightify/Reactant.git', :commit => 'b14e52e', :subspecs => ['Core', 'Result', 'TableView', 'CollectionView', 'Validation', 'StaticMap', 'ActivityIndicator', 'Configuration']
    pod 'ReactantUI', :git => 'https://github.com/Brightify/ReactantUI.git', :branch => 'conditions'
    pod 'ReactantLiveUI', :git => 'https://github.com/Brightify/ReactantUI.git', :branch => 'conditions', :configuration => 'Debug'
    pod 'IQKeyboardManagerSwift', '~> 6.1.1'
    pod 'JGProgressHUD', '~> 1.3.1'
    pod 'SwiftKeychainWrapper', '3.0.1'
    pod 'SwipeBack', '~> 1.0'
    pod 'AFImageHelper', '3.2.1'
    pod 'SwiftGen', '4.1.0'
    pod 'Material', '2.16.4'
    pod 'SuperDelegate', '0.9.0'
    pod 'SCLAlertView', '~> 0.8'
    pod 'Fabric', '~> 1.6.11'
    pod 'Crashlytics', '~> 3.8.4'
end

def test_pods
    pod 'Quick', '~> 1.1.0'
    pod 'Nimble', '~> 7.0'
    pod 'RxBlocking', '~> 4.0'
    pod 'RxNimble', '~> 4.0'
end

target 'TravelPlanner' do
    shared_pods
end

target 'TravelPlannerTests' do
    shared_pods
    test_pods
end

target 'TravelPlannerUITests' do
    shared_pods
    test_pods
end
