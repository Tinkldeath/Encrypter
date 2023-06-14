import Foundation


protocol KeychainWrapperProtocol {
    func set(value: Data, account: String) throws
    func get(account: String) throws -> Data?
    func remove(account: String) throws
}

class KeychainWrapper: KeychainWrapperProtocol {

    private let service = "TextEncrypter"
    private enum Errors: Error {
        case creatingError, operationError
    }
    
    func exists(account: String) throws -> Bool {
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: false
        ] as! CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        default:
            return false
        }
    }
    
    private func add(value: Data, account: String) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecValueData: value
        ] as CFDictionary, nil)
        guard status == errSecSuccess else {
            print(String(describing: status))
            throw Errors.creatingError
        }
    }
    
    private func update(value: Data, account: String) throws {
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
        ] as CFDictionary, [
            kSecValueData: value
        ] as CFDictionary)
        guard status == errSecSuccess else {
            throw Errors.operationError
        }
    }
    
    private func delete(account: String) throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
        ] as! CFDictionary)
        guard status == errSecSuccess else {
            throw Errors.operationError
        }
    }
    
    func set(value: Data, account: String) throws {
        if try exists(account: account) {
            try update(value: value, account: account)
        } else {
            try add(value: value, account: account)
        }
    }
    
    func get(account: String) throws -> Data? {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: true
        ] as! CFDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw Errors.operationError
        }
    }
    
    func remove(account: String) throws {
        if try exists(account: account) {
            try delete(account: account)
        } else {
            throw Errors.operationError
        }
    }
    
}
