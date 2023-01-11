//
//  Encryption.swift
//  Cashwalk
//
//  Created by Oh Sangho on 03/06/2019.
//  Copyright © 2019 Cashwalk, Inc. All rights reserved.
//

import Foundation
import CommonCrypto

enum HmacAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224
    var algorithm: CCHmacAlgorithm {
        var alg = 0
        switch self {
        case .sha1:
            alg = kCCHmacAlgSHA1
        case .md5:
            alg = kCCHmacAlgMD5
        case .sha256:
            alg = kCCHmacAlgSHA256
        case .sha384:
            alg = kCCHmacAlgSHA384
        case .sha512:
            alg = kCCHmacAlgSHA512
        case .sha224:
            alg = kCCHmacAlgSHA224
        }
        return CCHmacAlgorithm(alg)
    }
    var digestLength: Int {
        var len: Int32 = 0
        switch self {
        case .sha1:
            len = CC_SHA1_DIGEST_LENGTH
        case .md5:
            len = CC_MD5_DIGEST_LENGTH
        case .sha256:
            len = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            len = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            len = CC_SHA512_DIGEST_LENGTH
        case .sha224:
            len = CC_SHA224_DIGEST_LENGTH
        }
        return Int(len)
    }
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var toKey: String? {
        let key = self.md5
        
        var padding: String = ""
        if key.count < kCCKeySizeAES256 {
            for _ in key.count..<kCCKeySizeAES256 {
                padding = padding.appending("0")
            }
        }
        
        return padding.appending(key)
    }
    
    var toIV: String? {
        var padding: String = ""
        if self.count < kCCKeySizeAES128 {
            for _ in self.count..<kCCKeySizeAES128 {
                padding = padding.appending("0")
            }
        }
        
        return padding.appending(self)
    }
    
}

extension Data {
    private enum Error: Swift.Error {
        case encryptionError(status: CCCryptorStatus)
        case decryptionError(status: CCCryptorStatus)
        case keyDerivationError(status: CCCryptorStatus)
    }
    
    func encryptToAES256(key: Data, iv: Data) throws -> Data {
        let outputLength = self.count + kCCBlockSizeAES128
        var outputBuffer = [UInt8](repeating: 0,
                                        count: outputLength)
        var numBytesEncrypted = 0
        let status = CCCrypt(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             Array(key),
                             kCCKeySizeAES256,
                             Array(iv),
                             Array(self),
                             self.count,
                             &outputBuffer,
                             outputLength,
                             &numBytesEncrypted)
        guard status == kCCSuccess else {
            throw Error.encryptionError(status: status)
        }
        let outputBytes = iv + outputBuffer.prefix(numBytesEncrypted)
        return Data(outputBytes)
    }
    
    func decryptToAES256(key: Data) throws -> Data {
        let iv = self.prefix(kCCBlockSizeAES128)
        let cipherTextBytes = self
                               .suffix(from: kCCBlockSizeAES128)
        let cipherTextLength = cipherTextBytes.count
        
        var outputBuffer = [UInt8](repeating: 0,
                                        count: cipherTextLength)
        var numBytesDecrypted = 0
        let status = CCCrypt(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             Array(key),
                             kCCKeySizeAES256,
                             Array(iv),
                             Array(cipherTextBytes),
                             cipherTextLength,
                             &outputBuffer,
                             cipherTextLength,
                             &numBytesDecrypted)
        guard status == kCCSuccess else {
            throw Error.decryptionError(status: status)
        }
        
        let outputBytes = outputBuffer.prefix(numBytesDecrypted)
        return Data(outputBytes)
    }
    
}
