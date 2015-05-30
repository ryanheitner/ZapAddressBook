//
//  AppDelegate.swift
//  ZapAddressBook
//
//  Created by Ryan Heitner on 5/24/15.
//  Copyright (c) 2015 Ryan Heitner. All rights reserved.
//

import UIKit
import AdSupport
import AVFoundation;
import AudioToolbox;
import CFNetwork;
import CoreMedia;
import CoreTelephony;
import EventKit;
import EventKitUI;
import MediaPlayer;
import MessageUI;
import QuartzCore;
import Social;
import StoreKit;
import SystemConfiguration;
import WebKit;

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var adEngine : Int?
    var window: UIWindow?
    enum adEngineType: Int {
        case Vungle = 1, Flurry, AppLovin, Heyzap
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        HeyzapAds.startWithPublisherID("1c4baf246876fb1abfcec1d7fac6dc39");
        
        // Create UIWindow
        // Set rootViewController
        
        HeyzapAds.presentMediationDebugViewController();
        return true
//        syncRequest();
//        chooseAddProvider();
    }
    func syncRequest() {
        let urlPath: String = "http://www.googledrive.com/host/0B_jLCgnIJtptSkJfODVqTFVhYVE"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        println(response)
        let json : AnyObject!  = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: &error)
        let jsonDict = json as! [String : AnyObject]
        adEngine = jsonDict["adEngine"] as? Int;
    }
    func chooseAddProvider() {
        // let myIDFA = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        // 2496CF28-6CA7-4262-9FE0-22B72BBE19F2
        switch adEngine!
        {
        case adEngineType.Vungle.rawValue:
            // Vungle
            let appID = NSBundle.mainBundle().bundleIdentifier;
            let sdk : VungleSDK  = VungleSDK.sharedSDK()
            // start vungle publisher library
            sdk.startWithAppId(appID)
        case adEngineType.Flurry.rawValue:
            Flurry.startSession("WQS8HN9842FM4JC2BYBF")
        case adEngineType.AppLovin.rawValue:       // applovin
            let appLovinKey = "CMwmdZaeQ_Xx39mGzVof_IEkJ7WZbshpDbTr98Ta70VBAGR8nDomW0Tq8-Olr4T3g6uqEMOMNvXX9-gwBTghU9" // app lovin
            ALSdk.initializeSdk()
        case adEngineType.Heyzap.rawValue:
            // Your Publisher ID is: 1c4baf246876fb1abfcec1d7fac6dc39
            HeyzapAds.startWithPublisherID("1c4baf246876fb1abfcec1d7fac6dc39");
            HZVideoAd.fetch()

        default:
            println("Something else")
        }
        // Override point for customization after application launch.
        // flurry
        
        
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

