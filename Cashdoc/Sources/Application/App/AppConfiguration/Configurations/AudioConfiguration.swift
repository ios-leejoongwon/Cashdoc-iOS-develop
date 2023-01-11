//
//  File.swift
//  Cashdoc
//
//  Created by Taejune Jung on 22/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import AVFoundation

struct AudioConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let audioSession = AVAudioSession.sharedInstance()
        if #available(iOS 10.0, *) {
            try? audioSession.setCategory(.ambient, mode: .default, options: [])
        }
        try? audioSession.setActive(true)
    }
}
