import Foundation
import RxSwift


protocol FilesUseCaseProtocol {
    
    var files: BehaviorSubject<[FileData]> { get }
    
    func getFiles()
    func saveFile(_ name: String, _ enctype: Enctype, _ content: String)
    func updateFile(_ file: FileData)
    func deleteFile(_ file: FileData)
    func decryptFile(_ file: FileData) -> String
    func fileForId(_ id: String) -> FileData
    
}


class FilesUseCase: FilesUseCaseProtocol {
    
    private(set) var files: BehaviorSubject<[FileData]> = BehaviorSubject(value: [])
    private let filesDataStore: FilesDataStoreProtocol = FilesDataStore()
    
    func getFiles() {
        self.files.onNext(self.filesDataStore.fetch())
    }
    
    func saveFile(_ name: String, _ enctype: Enctype, _ content: String) {
        let _ = self.filesDataStore.create(name, enctype, content)
        self.files.onNext(self.filesDataStore.fetch())
    }
    
    func updateFile(_ file: FileData) {
        self.files.onNext(self.filesDataStore.update(file))
    }
    
    func deleteFile(_ file: FileData) {
        self.files.onNext(self.filesDataStore.delete(file))
    }
    
    func decryptFile(_ file: FileData) -> String {
        return self.filesDataStore.decrypted(file)
    }
    
    func fileForId(_ id: String) -> FileData {
        let file = self.filesDataStore.fetch().first(where: { $0.id == id })!
        return file
    }
    
}
