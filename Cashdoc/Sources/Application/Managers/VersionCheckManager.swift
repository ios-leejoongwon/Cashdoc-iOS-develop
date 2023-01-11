//
//  VersionCheckManager.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/07/15.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

enum VersionCheckManager {
    
    enum VersionCheck {
        case 업데이트있음
        case 업데이트없음
    }
    
    private enum VersionCheckPointResult {
        case result(_ versionCheck: VersionCheck)
        case nextCheckPoint
    }
    
    private enum VersionCheckPoint {
        case major(currentVersion: String, targetVersion: String)
        case minor(currentVersion: String, targetVersion: String)
        case hotfix(currentVersion: String, targetVersion: String)
        
        private var index: Int {
            switch self {
            case .major:
                return 0
            case .minor:
                return 1
            case .hotfix:
                return 2
            }
        }
        
        var result: VersionCheckPointResult {
            let currentComponents: [String]
            let targetComponents: [String]
            
            switch self {
            case .major(let currentVersion, let targetVersion), .minor(let currentVersion, let targetVersion), .hotfix(let currentVersion, let targetVersion):
                currentComponents = currentVersion.components(separatedBy: ".")
                targetComponents = currentVersion.checkVersionCount(to: targetVersion).components(separatedBy: ".")
            }
             
            guard let currentElement = currentComponents[safe: index], let targetElement =
                    targetComponents[safe: index] else {
                return .result(.업데이트없음)
            }
             
            if currentElement == targetElement {
                return .nextCheckPoint
            } else {
                if targetElement > currentElement {
                    switch self {
                    case .major:
                        return .result(.업데이트있음)
                    case .minor:
                        return .result(.업데이트있음)
                    case .hotfix:
                        return .result(.업데이트있음)
                    }
                } else {
                    return .result(.업데이트없음)
                }
            }
        } 
    }
    
    static func check(with targetVersion: String) -> VersionCheck {
        guard targetVersion.isEmpty == false else {return .업데이트없음}
        
        let major = VersionCheckPoint.major(currentVersion: getAppVersion(), targetVersion: targetVersion)
        let minor = VersionCheckPoint.minor(currentVersion: getAppVersion(), targetVersion: targetVersion)
        let hotfix = VersionCheckPoint.hotfix(currentVersion: getAppVersion(), targetVersion: targetVersion)
        
       switch major.result {
        case .result(let versionCheck):
            return versionCheck
        case .nextCheckPoint:
            switch minor.result {
            case .result(let versionCheck):
                return versionCheck
            case .nextCheckPoint:
                switch hotfix.result {
                case .result(let versionCheck):
                    return versionCheck
                case .nextCheckPoint:
                    return .업데이트없음
                }
            }
        }
    }
    
}

private extension String {
    
    func checkVersionCount(to targetVersion: String) -> String {
        let versionDelimiter = "."
        var result: String
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count
        
        if spareCount == 0 {
            result = targetVersion
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = targetComponents.joined(separator: versionDelimiter)
        }
        return result
    }
    
}
