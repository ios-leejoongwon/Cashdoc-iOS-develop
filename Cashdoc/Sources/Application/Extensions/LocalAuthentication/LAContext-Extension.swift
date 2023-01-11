//
//  LAContext-Extension.swift
//  Cashdoc
//
//  Created by Taejune Jung on 30/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import LocalAuthentication

extension LAContext {
    func bioType() -> LABiometryType {
        let authContext = LAContext()
        var error: NSError?
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch authContext.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        } else {
            return .none
        }
    }
}
