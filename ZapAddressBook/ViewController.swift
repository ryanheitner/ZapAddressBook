//
//  ViewController.swift
//  Zap My Address Book
//
//  Created by Ryan Heitner on 11/28/14.
//  Copyright (c) 2014 TalkingTalk. All rights reserved.
//

import UIKit
import AddressBookUI
import AddressBook
import CloudKit


func documentDir() -> NSURL {
    let fileManager                     = NSFileManager.defaultManager()
    let urls                            = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls.first as! NSURL ;
}

class ViewController: UIViewController,
    iCloudDelegate,
    ABPeoplePickerNavigationControllerDelegate
{
    var adEngineType: AppDelegate.adEngineType?

    
    
    override func viewDidLoad() {
        // Setup iCloud
        println("view did load")
        iCloud.sharedCloud().delegate       = self;// Set this if you plan to use the delegate
        iCloud.sharedCloud().verboseLogging = true// We want detailed feedback about what's going on with iCloud, this is OFF by default
        iCloud.sharedCloud().setupiCloudDocumentSyncWithUbiquityContainer(nil);
    }
    
    @IBAction func deleteButtonPushed() {
        var error: NSError
        let appDelegate =  (UIApplication.sharedApplication().delegate as! AppDelegate)
        switch appDelegate.adEngine!
        {
        case AppDelegate.adEngineType.Vungle.rawValue:
            // Vungle
            VungleSDK.sharedSDK().playAd(self, error: nil)
        case AppDelegate.adEngineType.Flurry.rawValue:
            println("flurry");
        case AppDelegate.adEngineType.AppLovin.rawValue:       // applovin
            println("AppLovin");
        case AppDelegate.adEngineType.Heyzap.rawValue:
            HZVideoAd.show()
        default:
            println("Something else")
        }
        //#define APP_DELEGATE ((HomeLyncAppDelegate *)[[UIApplication sharedApplication] delegate])

        
        return;
        ViewController.deleteAddressBook();
    }
    
    class func saveDataToAddressBook (data:NSData) -> Bool {
        //            ABAddressBookAddRecord(<#addressBook: ABAddressBook!#>, <#record: ABRecord!#>, error: UnsafeMutablePointer<Unmanaged<CFError>?>)
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook?     = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        
        
        let readPeople : NSArray            = vCardSerialization.addressBookRecordsWithVCardData(data, error: nil);
        for readPerson in readPeople {
            ABAddressBookAddRecord(addressBook, readPerson as ABRecordRef, &error)
            println("restore")
            
        }
        
        let save                            = ABAddressBookSave(addressBook, &error);
        return save
    }

    @IBAction func restoreButtonPushed() {
        println("restoreButtonPushed")
        println("\(__FUNCTION__) in \(__FILE__)")
        
        
        
        
        let documentsPath                   = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let fileName                        = "myfile.txt"
        
        let myPath                          = documentsPath.stringByAppendingPathComponent(fileName)
        let fileManager                     = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(myPath)) {
            let myData                          = fileManager.contentsAtPath(myPath);
            ViewController.saveDataToAddressBook(myData!)
        } else {
            // Try get it from the cloud
            iCloud.sharedCloud().retrieveCloudDocumentWithName(fileName, completion: { (document:UIDocument!, data:NSData!, error:NSError!) -> Void in
                if (error == nil) {
                    ViewController.saveDataToAddressBook(data!)
                }
            })
        }
    }
    
    class func deleteAddressBook() {
        // make sure user hadn't previously denied access
        
        let status                          = ABAddressBookGetAuthorizationStatus()
        if status == .Denied || status == .Restricted {
            // user previously denied, to tell them to fix that in settings
            return
        }
        
        // open it
        
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook?     = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if addressBook == nil {
            println(error?.takeRetainedValue())
            return
        }
        
        // request permission to use it
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            
            if !granted {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                return
            }
            
            let people : NSArray                = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray as [ABRecord];
            //            let docURL = documentDir();
            let documentsPath                   = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            
            let fileName                        = "myfile.txt"
            let myPath                          = documentsPath.stringByAppendingPathComponent(fileName)
            // let myURL : NSURL = NSURL(string:"address.txt", relativeToURL:docURL) as NSURL!
            let vCards : NSData                 = ABPersonCreateVCardRepresentationWithPeople(people).takeRetainedValue();
            
            
            let fileManager                     = NSFileManager.defaultManager()
            // let myPath = myURL.absoluteString
            let success                         = fileManager.createFileAtPath(myPath, contents: vCards, attributes: nil)
            if (!success) {
                
                println("backup failed");
                NSLog("ns log backup failed");
                return
            }
            iCloud.sharedCloud().saveAndCloseDocumentWithName(fileName, withContent: vCards, completion: { (document:UIDocument!, data:NSData!, error:NSError!) -> Void in
                if (error != nil) {
                    NSLog("failed to save to cloud");
                    return
                } else {
                    NSLog("saved to cloud");
                }
            })
            //            [[iCloud sharedCloud] saveAndCloseDocumentWithName:@"Name.ext" withContent:[NSData data] completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
            //                if (error == nil) {
            //                    // Code here to use the UIDocument or NSData objects which have been passed with the completion handler
            //                }
            //            }];
            
            var error: Unmanaged<CFError>?
            for person in people {
                var removed                         = ABAddressBookRemoveRecord(addressBook, person, &error) ;
                println("Removed \(person.name) removed at \(__FILE__):\(__LINE__)");
            }
            let save                            = ABAddressBookSave(addressBook, &error);
            
            
            
            
            // (__bridge ABRecordRef)[[vCardSerialization addressBookRecordsWithVCardData:myData error:nil] firstObject];
            
            
            // Create a URL to the local file
            //            let container = CKContainer.defaultContainer()
            //            let privateDatabase = container.privateCloudDatabase
            //            let asset = CKAsset(fileURL: docURL);
            
            
            //
            
        }
    }
    
    //MARK: - ICloud Delegates
    func iCloudDidFinishInitializingWitUbiquityToken(cloudToken: AnyObject!, withUbiquityContainer ubiquityContainer: NSURL!) {
        NSLog("Ubiquity container initialized. You may proceed to perform document operations.");
    }
    func iCloudAvailabilityDidChangeToState(cloudIsAvailable: Bool, withUbiquityToken ubiquityToken: AnyObject!, withUbiquityContainer ubiquityContainer: NSURL!)
    {
        NSLog("iCloudAvailabilityDidChangeToState \(cloudIsAvailable)");
        
        
    }
    func iCloudFilesDidChange(files: NSMutableArray!, withNewFileNames fileNames: NSMutableArray!) {
        NSLog("iCloudFilesDidChange \(fileNames)");
    }
    
    func refreshCloudList() {
        iCloud.sharedCloud().updateFiles();
    }
    
    func refreshCloudListAfterSetup() {
        
        // Reclaim delegate and then update files
        iCloud.sharedCloud().delegate       = self;
        iCloud.sharedCloud().updateFiles();
        
    }
    
}

