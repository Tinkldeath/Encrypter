import Foundation
import CryptoKit


protocol CryptoServiceProtocol {
    
    func encrypt(_ content: String, _ enctype: Enctype, _ key: Data) -> Data?
    func decrypt(_ content: Data, _ enctype: Enctype, _ key: Data) -> Data?
    func randomKey() -> Data
    
}


class CryptoService: CryptoServiceProtocol {
    
    private var worker: SecretDataWorker = AESSecretDataWorker()
    
    func encrypt(_ content: String, _ enctype: Enctype, _ key: Data) -> Data? {
        switch enctype {
        case .aes:
            self.worker = AESSecretDataWorker()
            return self.worker.encryptData(data: content.data(using: .unicode)!, key: key)
        case .chaChaPoly:
            self.worker = ChaChaPolySecretDataWorker()
            return self.worker.encryptData(data: content.data(using: .unicode)!, key: key)
        }
    }
    
    func decrypt(_ content: Data, _ enctype: Enctype, _ key: Data) -> Data? {
        switch enctype {
        case .aes:
            self.worker = AESSecretDataWorker()
            return self.worker.decryptData(data: content, key: key)
        case .chaChaPoly:
            self.worker = ChaChaPolySecretDataWorker()
            return self.worker.decryptData(data: content, key: key)
            
        }
    }
    
    func randomKey() -> Data {
        let key = SymmetricKey(size: .bits256)
        return key.withUnsafeBytes({ Data($0) })
    }
    
}
