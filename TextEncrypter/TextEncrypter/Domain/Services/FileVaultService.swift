import Foundation


protocol FileVaultServiceProtocol {
    
    func readFile(_ path: URL) -> String?
    func readFileData(_ path: URL) -> Data?
    func createFile(_ path: URL, _ content: Data) -> Bool
    func updateFile(_ path: URL, _ content: Data) -> Bool
    func deleteFile(_ path: URL) -> Bool
    
    func saveDir() -> URL
}

class FileVaultService: FileVaultServiceProtocol {
    
    func readFile(_ path: URL) -> String? {
        do {
            let last = path.lastPathComponent
            let newPath = self.saveDir().appending(component: last)
            let content = try Data(contentsOf: newPath)
            let string = String(data: content, encoding: .unicode)
            return string
        } catch {
            print(String(describing: error))
        }
        return nil
    }
    
    func readFileData(_ path: URL) -> Data? {
        do {
            let last = path.lastPathComponent
            let newPath = self.saveDir().appending(component: last)
            let content = try Data(contentsOf: newPath)
            return content
        } catch {
            print(String(describing: error))
        }
        return nil
    }
    
    func createFile(_ path: URL, _ content: Data) -> Bool {
        do {
            let last = path.lastPathComponent
            let newPath = self.saveDir().appending(component: last)
            try content.write(to: newPath)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
    func updateFile(_ path: URL, _ content: Data) -> Bool {
        do {
            let last = path.lastPathComponent
            let newPath = self.saveDir().appending(component: last)
            try content.write(to: newPath)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
    func deleteFile(_ path: URL) -> Bool {
        do {
            let last = path.lastPathComponent
            let newPath = self.saveDir().appending(component: last)
            try FileManager.default.removeItem(at: newPath)
            return true
        } catch {
            print(String(describing: error))
        }
        return false
    }
    
    func saveDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}
