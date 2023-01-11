//
//  Codable+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

extension Encodable {
    func encode(_ encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(_ decoder: JSONDecoder = JSONDecoder(), data: Data) throws -> Self {
        return try decoder.decode(self, from: data)
    }
}
