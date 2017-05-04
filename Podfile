source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

# TODO Change branch to version once released.

def shared_pods
    pod 'Firebase', '~> 3.14.0', :subspecs => ['Auth', 'Crash', 'Database']
    pod 'SwiftDate', '~> 4.0.13'
    pod 'Fetcher', :git => 'https://github.com/Brightify/Fetcher.git', :branch => 'develop'
    pod 'Fetcher/RxFetcher', :git => 'https://github.com/Brightify/Fetcher.git', :branch => 'develop'
    pod 'DataMapper', '~> 0.1'
    pod 'Reactant', '~> 1.0', :subspecs => ['Core', 'Result', 'TableView', 'CollectionView', 'Validation', 'StaticMap', 'ActivityIndicator', 'Configuration']
    pod 'ReactantUI', '~> 0.1'
    pod 'ReactantLiveUI', '~> 0.1', :configuration => 'Debug'
    pod 'IQKeyboardManagerSwift', '~> 4.0.5'
    pod 'JGProgressHUD', '~> 1.3.1'
    pod 'SwiftKeychainWrapper', '3.0.1'
    pod 'SwipeBack', '~> 1.0'
    pod 'AFImageHelper', '3.2.1'
    pod 'SwiftGen', '4.1.0'
    pod 'Material', '2.4.10'
    pod 'SuperDelegate', '0.9.0'
    pod 'SCLAlertView', '~> 0.7.0'
    pod 'Fabric', '~> 1.6.11'
    pod 'Crashlytics', '~> 3.8.4'
end

def test_pods
    pod 'Quick', '~> 1.1.0'
    pod 'Nimble', '~> 5.0'
    pod 'RxBlocking', '~> 3.0'
    pod 'RxNimble', '~> 1.0'
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
