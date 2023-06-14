import Foundation


protocol KeyServiceProtocol {
    
    func getKey(_ identity: String) -> Data?
    func saveKey(_ key: Data, _ identity: String) -> Bool
    func updateKey(_ key: Data, _ identity: String) -> Bool
    func deleteKey(_ identity: String) -> Bool
    
}


class KeyService: KeyServiceProtocol {
    
    private let keychainWrapper: KeychainWrapperProtocol = KeychainWrapper()
    
    func getKey(_ identity: String) -> Data? {
        do {
            let key = try self.keychainWrapper.get(account: identity)
            return key
        } catch {
            print(String(describing: error))
        }
        return nil
    }
    
    func saveKey(_ key: Data, _ identity: String) -> Bool {
        do {
            try self.keychainWrapper.set(value: key, account: identity)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
    func updateKey(_ key: Data, _ identity: String) -> Bool {
        do {
            try self.keychainWrapper.set(value: key, account: identity)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
    func deleteKey(_ identity: String) -> Bool {
        do {
            try self.keychainWrapper.remove(account: identity)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
}
