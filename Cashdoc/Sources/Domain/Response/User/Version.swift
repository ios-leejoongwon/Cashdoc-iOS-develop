//
//  Version.swift
//  Cashdoc
//
//  Created by Oh Sangho on 28/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct Version: Decodable {
    let androidMajor: String
    let androidMinor: String
    var iosMajor: String
    var iosMinor: String
    let androidUpdateURL: String
}
