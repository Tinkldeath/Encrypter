import Foundation
import CryptoKit


protocol SecretDataWorker {
    func encryptData(data: Data, key: Data) -> Data?
    func decryptData(data: Data, key: Data) -> Data?
}


struct AESSecretDataWorker: SecretDataWorker {
    
    func encryptData(data: Data, key: Data) -> Data? {
        do {
            let cipher = try AES.GCM.seal(data, using: SymmetricKey(data: key))
            return cipher.combined
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
    func decryptData(data: Data, key: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: key))
            return decryptedData
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
}

struct ChaChaPolySecretDataWorker: SecretDataWorker {
    
    func encryptData(data: Data, key: Data) -> Data? {
        do {
            let chiper = try ChaChaPoly.seal(data, using: SymmetricKey(data: key))
            return chiper.combined
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
    func decryptData(data: Data, key: Data) -> Data? {
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: SymmetricKey(data: key))
            return decryptedData
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
}
