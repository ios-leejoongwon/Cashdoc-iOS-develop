//
//  LinkManager.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SafariServices

enum LinkManager {
    
    // MARK: - Internal methods
    
    static func open(type: LinkType, url: String) {
        let urlencodeParam = RemoteConfigManager.shared.getString(from: .ios_urlencode_param) ?? "\"%<> [\\]^`{|}"
        let allowedQueryParamAndKey = NSCharacterSet(charactersIn: urlencodeParam).inverted
        Log.al("url = \(url)")
        switch type {
        case .inLink(let rootViewController):
            if let openURL = URL(string: url) {
                let controller = SFSafariViewController(url: openURL)
                controller.setTintColor()
                rootViewController.present(controller, animated: true, completion: nil)
            } else {
                if let encodedString = url.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) {
                    if let openURL = URL(string: encodedString) {
                        let controller = SFSafariViewController(url: openURL)
                        controller.setTintColor()
                        rootViewController.present(controller, animated: true, completion: nil)
                    }
                }
            }
        case .outLink:
            if let openURL = URL(string: url) {
                Log.al("openURL1")
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            } else {
                if let encodedString = url.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) {
                    if let openURL = URL(string: encodedString) {
                        Log.al("openURL2")
                        UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
}
