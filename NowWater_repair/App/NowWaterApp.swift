//
//  NowWaterApp.swift
//  NowWater
//
//  Created by yangjian on 2023/10/10.
//

import ComposableArchitecture
import FBSDKCoreKit
import SwiftUI
import GADUtil
import AppTrackingTransparency

@main
struct NowWater_repairApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init(){
        NotificationHelper.shared.register()
        GADUtil.share.requestConfig()
    }
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppReducer.State()) {
                AppReducer()
            }).onAppear{
                ATTrackingManager.requestTrackingAuthorization { _ in
                }
            }
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
    }
}
