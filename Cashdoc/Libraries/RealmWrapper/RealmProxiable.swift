import RealmSwift

public protocol RealmProxiable {
    associatedtype RealmManager where RealmManager: RealmManageable
    var rm: RealmManager { get }
}

public extension RealmProxiable {
    
    var rm: RealmManager {
        return RealmManager()
    }
    
    func query<T: Object>(_ type: T.Type = T.self, filter: String? = nil, sortProperty: String? = nil, ordering: OrderingType = .ascending) -> RealmQuery<T> {
        guard let realm = try? Realm(configuration: rm.createConfiguration()) else {
            DBManager.removeRealmFile(realmName: rm.fileName)
            fatalError("RealmProxiable not find to database \(rm.fileName),\(type)")
//            if let newRealm = try? Realm(configuration: rm.createConfiguration()) {
//                let newResult = newRealm.objects(type)
//                return RealmQuery(results: newResult)
//            } else {
//                fatalError("RealmProxiable not find to database \(rm.fileName),\(type)")
//            }
        }

        var results = realm.objects(type)
        if let filter = filter {
            results = results.filter(filter)
        }
        if let sortProperty = sortProperty {
            results = results.sorted(byKeyPath: sortProperty, ascending: ordering == .ascending)
        }
        
        return RealmQuery(results: results)
    }
    
}
