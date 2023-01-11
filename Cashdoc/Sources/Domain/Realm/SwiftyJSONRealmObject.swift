//
//  SwiftyJSONRealmObject.swift
//  SwiftyJSONRealmObject
//
//  Created by Alex Corlatti on 07/11/2016.
//  Copyright (c) 2016 Alex Corlatti. All rights reserved.
//

import RealmSwift
import SwiftyJSON

/**
 SwiftyJSONRealmObject
 - Description : Object derived from Realm object and is the base for all the objects that want be mapped from JSON
 */
@objcMembers
open class SwiftyJSONRealmObject: Object {

    required convenience public init(json: JSON) {

        self.init()

    }

    // realmObjt에 Array화
    open class func createList< T>(ofType type: T.Type, fromJson json: JSON) -> List<T> where T: SwiftyJSONRealmObject {
        let list = List<T>()
        for (_, singleJson): (String, JSON) in json {
            list.append(T(json: singleJson))
        }
        return list
    }

    open class func createObjList< T>(ofType type: T.Type, fromJson json: JSON) -> [SwiftyJSONRealmObject] where T: SwiftyJSONRealmObject {
        var list = [SwiftyJSONRealmObject]()
        for (_, singleJson): (String, JSON) in json {
            list.append(T(json: singleJson))
        }
        return list
    }
}
