//
//  URL-Extensions.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/03.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        guard let item = url.queryItems?.first(where: { $0.name == queryParamaterName }) else { return nil }
        return item.value ?? ""
    }
    
    mutating func append(_ queryItem: String, value: String?) {
        
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        // returns the url from new url components
        self = urlComponents.url!
    }
    
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
    
    func value(for paramater: String) -> String? {
        let queryItems = URLComponents(string: self.absoluteString)?.queryItems
        let queryItem = queryItems?.filter({$0.name == paramater}).first
        let value = queryItem?.value
        return value
    }
    
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
