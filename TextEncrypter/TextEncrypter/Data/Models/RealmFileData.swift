import Foundation
import RealmSwift


class RealmFileData: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var enctype: String
    @Persisted var filePath: String
    
    func setup(_ name: String, _ enctype: String, _ filePath: String) {
        self.name = name
        self.enctype = enctype
        self.filePath = filePath
    }
    
}
