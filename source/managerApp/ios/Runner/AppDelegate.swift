import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override  func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey:Any]?)->Bool{
      // Other intialization code…

      UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
      GeneratedPluginRegistrant.register(with:self)

      GMSServices.provideAPIKey("AIzaSyAjkgfUAoTE7Lj-8I7UeaSK7caRoocDqTs")
      

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
