//
//  Object.swift
//  vKalc
//
//  Created by cis on 26/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
struct searchedTopic {
    var answer:String       =   ""
    var date:String         =   ""
    var realDate:Date       =   Date()
    var fullJSON:String     =   ""
    var image:String        =   ""
    var question:String     =   ""
    var scannerVal:String   =   ""
    var time:Int            =   0
    var title:String        =   ""
    var userEmail:String    =   ""
    var userId:String       =   ""
    var userName:String     =   ""
    
    init(json:[String:Any]) {
        self.answer         = json["answer"] as? String ?? ""
        self.date           = json["date"] as? String ?? ""
        self.fullJSON       = json["fullJSON"] as? String ?? ""
        self.image          = json["image"] as? String ?? ""
        self.question       = json["question"] as? String ?? ""
        self.scannerVal     = json["scannerVal"] as? String ?? ""
        self.time           = json["time"] as? Int ?? 0
        self.realDate       = Date(timeIntervalSince1970: Double(time))
        self.title          = json["title"] as? String ?? ""
        self.userEmail      = json["userEmail"] as? String ?? ""
        self.userId         = json["userId"] as? String ?? ""
        self.userName       = json["userName"] as? String ?? ""
    }
}

struct Faq {
    var id:Int              =   0
    var question:String     =   ""
    var answer:String       =   ""
    
    init(json:[String:Any]) {
        self.id             = json["id"] as? Int ?? 0
        self.question       = json["question"] as? String ?? ""
        self.answer         = json["answer"] as? String ?? ""
    }
}

struct MainObject: Codable {
    let queryresult: Queryresult?
}

struct Queryresult: Codable {
    let success: Bool?
    let numpods: Int?
    let pods: [Pod]?
}

struct Pod: Codable {
    let title :String?
    let scanner: String?
    let position: Int?
    let numsubpods: Int?
    let subpods: [Subpod]?
}


struct Subpod: Codable {
    let title: String?
    let img: Img?
    let plaintext: String?
}

struct Img: Codable {
    let src: String?
    let width, height: Int?
}

public enum PreferenceType: String {
    
    case about = "General&path=About"
    case accessibility = "General&path=ACCESSIBILITY"
    case airplaneMode = "AIRPLANE_MODE"
    case autolock = "General&path=AUTOLOCK"
    case cellularUsage = "General&path=USAGE/CELLULAR_USAGE"
    case brightness = "Brightness"
    case bluetooth = "Bluetooth"
    case dateAndTime = "General&path=DATE_AND_TIME"
    case facetime = "FACETIME"
    case general = "General"
    case keyboard = "General&path=Keyboard"
    case castle = "CASTLE"
    case storageAndBackup = "CASTLE&path=STORAGE_AND_BACKUP"
    case international = "General&path=INTERNATIONAL"
    case locationServices = "LOCATION_SERVICES"
    case accountSettings = "ACCOUNT_SETTINGS"
    case music = "MUSIC"
    case equalizer = "MUSIC&path=EQ"
    case volumeLimit = "MUSIC&path=VolumeLimit"
    case network = "General&path=Network"
    case nikePlusIPod = "NIKE_PLUS_IPOD"
    case notes = "NOTES"
    case notificationsId = "NOTIFICATIONS_ID"
    case phone = "Phone"
    case photos = "Photos"
    case managedConfigurationList = "General&path=ManagedConfigurationList"
    case reset = "General&path=Reset"
    case ringtone = "Sounds&path=Ringtone"
    case safari = "Safari"
    case assistant = "General&path=Assistant"
    case sounds = "Sounds"
    case softwareUpdateLink = "General&path=SOFTWARE_UPDATE_LINK"
    case store = "STORE"
    case twitter = "TWITTER"
    case facebook = "FACEBOOK"
    case usage = "General&path=USAGE"
    case video = "VIDEO"
    case vpn = "General&path=Network/VPN"
    case wallpaper = "Wallpaper"
    case wifi = "WIFI"
    case tethering = "INTERNET_TETHERING"
    case blocked = "Phone&path=Blocked"
    case doNotDisturb = "DO_NOT_DISTURB"
    
}
