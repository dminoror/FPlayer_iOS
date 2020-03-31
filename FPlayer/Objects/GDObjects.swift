//
//  GDObjects.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/2/21.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class GDAccount {
    var driveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    
    var userId: String? {
        get {
            return googleUser?.userID
        }
    }
    var fullName: String? {
        get {
            return googleUser?.profile.name
        }
    }
    var givenName: String? {
        get {
            return googleUser?.profile.givenName
        }
    }
    var email: String? {
        get {
            return googleUser?.profile.email
        }
    }
    
    convenience init(user: GIDGoogleUser) {
        self.init()
        googleUser = user
        driveService.authorizer = user.authentication.fetcherAuthorizer()
    }
}

enum IconType: String {
    case none = ""
    case gdfolder = "googleDriveFolderIcon"
    case flac = "flacIcon"
    case m4a = "aacIcon"
    case mp3 = "mp3Icon"
}

extension GTLRDrive_File {
    func getIconType() -> IconType {
        if let mimeType = self.mimeType {
            if (mimeType.contains("application") && mimeType.contains("folder")) {
                return .gdfolder
            }
            else if (mimeType.contains("audio")) {
                if (mimeType.contains("mp3")) {
                    return .mp3
                }
                else if (mimeType.contains("flac")) {
                    return .flac
                }
                else if (mimeType.contains("m4a")) {
                    return .m4a
                }
            }
        }
        return .none
    }
}
