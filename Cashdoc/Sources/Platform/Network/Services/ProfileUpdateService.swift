//
//  ProfileUpdateService.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/05/04.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Moya

typealias Profile = (image: UIImage?, nicknameText: String?, removeProfile: Bool?)

enum ProfileUpdateService {
    case putProfile(with: Profile)
}

extension ProfileUpdateService: TargetType {

    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .putProfile:
            return "account"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .putProfile:
            return .put
        }
    }
    
    var task: Task {
        var parameters = [String: Any]()
        switch self {
        case .putProfile(let profile):
            parameters["access_token"] = AccessTokenManager.accessToken
            var formData = [Moya.MultipartFormData]()
            
            if let removeProfile = profile.removeProfile {
                if removeProfile, let strRemoveProfile = String(removeProfile).data(using: .utf8) {
                    formData.append(Moya.MultipartFormData(provider: .data(strRemoveProfile), name: "removeImage"))
                } else {
                    if let imageData = profile.image?.jpegData(compressionQuality: 1) {
                        formData.append(Moya.MultipartFormData(provider: .data(imageData), name: "person.image", fileName: "user.jpeg", mimeType: "image/jpeg"))
                    }
                }
            }
            
            if let nickname = profile.nicknameText?.data(using: String.Encoding.utf8) {
                formData.append(Moya.MultipartFormData(provider: .data(nickname), name: "nickname"))
            }

            Log.al("formData = \(formData)")
            return .uploadCompositeMultipart(formData, urlParameters: parameters)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .putProfile:
            return API.CASHDOC_HEADERS
        }
    }
}
