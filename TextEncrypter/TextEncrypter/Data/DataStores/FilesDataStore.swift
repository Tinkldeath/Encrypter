import Foundation
import RealmSwift


protocol FilesDataStoreProtocol {
    
    func fetch() -> [FileData]
    func create(_ name: String, _ enctype: Enctype, _ content: String) -> [FileData]
    func update(_ file: FileData) -> [FileData]
    func delete(_ file: FileData) -> [FileData]
    func decrypted(_ file: FileData) -> String
    
}


class FilesDataStore {
    
    private let realm: Realm
    private let fileVaultService: FileVaultServiceProtocol
    private let cryptoService: CryptoServiceProtocol
    private let keyService: KeyServiceProtocol
    
    init() {
        do {
            Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
            self.realm = try Realm(configuration: .defaultConfiguration)
            self.fileVaultService = FileVaultService()
            self.cryptoService = CryptoService()
            self.keyService = KeyService()
        } catch {
            fatalError("Realm is broken: \(String(describing: error))")
        }
    }
    
}

extension FilesDataStore: FilesDataStoreProtocol {
    
    func fetch() -> [FileData] {
        let files = self.realm.objects(RealmFileData.self).toArray(ofType: RealmFileData.self)
        return files.map({ FileData(
                id: $0._id.stringValue,
                name: $0.name,
                path: URL(filePath: $0.filePath),
                enctype: Enctype(rawValue: $0.enctype)!,
                content: self.fileVaultService.readFile(URL(filePath: $0.filePath)) ?? "Unable to read file"
            )
        })
    }
    
    func create(_ name: String, _ enctype: Enctype, _ content: String) -> [FileData] {
        do {
            let key = self.cryptoService.randomKey()
            let path = self.fileVaultService.saveDir().appending(component: name).appendingPathExtension("txt")
            var id = ""
            try self.realm.write({
                let object = RealmFileData()
                object.setup(name, enctype.rawValue, path.formatted())
                id = object._id.stringValue
                self.realm.add(object)
            })
            if self.keyService.saveKey(key, id) {
                if let data = self.cryptoService.encrypt(content, enctype, key) {
                    let _ = self.fileVaultService.createFile(path, data)
                }
            }
        } catch {
            print(String(describing: error))
        }
        return self.fetch()
    }
    
    func update(_ file: FileData) -> [FileData] {
        let object = self.realm.objects(RealmFileData.self).first(where: { $0._id.stringValue == file.id })!
        do {
            let key = self.cryptoService.randomKey()
            if self.keyService.updateKey(key, file.id) {
                if let data = self.cryptoService.encrypt(file.content, file.enctype, key) {
                    if self.fileVaultService.updateFile(file.path, data) {
                        try self.realm.write({
                            object.setup(file.name, file.enctype.rawValue, file.path.formatted())
                        })
                    }
                }
            }
        } catch {
            print(String(describing: error))
        }
        return self.fetch()
    }
    
    func delete(_ file: FileData) -> [FileData] {
        let object = self.realm.objects(RealmFileData.self).first(where: { $0._id.stringValue == file.id })!
        do {
            try self.realm.write({
                self.realm.delete(object)
            })
            if self.keyService.deleteKey(file.id) {
                let _ = self.fileVaultService.deleteFile(file.path)
            }
        } catch {
            print(String(describing: error))
        }
        return self.fetch()
    }
    
    func decrypted(_ file: FileData) -> String {
        if let key = self.keyService.getKey(file.id) {
            if let data = self.cryptoService.decrypt(self.fileVaultService.readFileData(file.path)!, file.enctype, key) {
                return String(data: data, encoding: .unicode) ?? "Unable to decode data"
            }
        }
        return "Unable to decode data"
    }
    
}

extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
    
}
