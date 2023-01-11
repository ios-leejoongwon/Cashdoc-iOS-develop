//
//  JailBreakChecker.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/06/25.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class JailBreakChecker {
    class func checkJail() {
        if hasJailbreak() {
            let dialog = UIAlertController(title: nil, message: "고객님의 정보 보호를 위해\n탈옥이나 루팅된 단말에서는\n서비스를 이용하실 수 없습니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
                exit(0)
            }
            dialog.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(dialog, animated: true, completion: nil)
        }
    }
    
    class func hasJailbreak() -> Bool {
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }
        #if arch(i386) || arch(x86_64)
        return false
        #else
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            return true
        }
        if canOpen(path: "/Applications/Cydia.app") ||
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            canOpen(path: "/bin/bash") ||
            canOpen(path: "/usr/sbin/sshd") ||
            canOpen(path: "/etc/apt") ||
            canOpen(path: "/usr/bin/ssh") {
            return true
        }
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
        #endif
    }
    
    class private func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
}
