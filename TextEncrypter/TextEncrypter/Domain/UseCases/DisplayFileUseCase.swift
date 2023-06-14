import Foundation


protocol DisplayFileUseCaseProtocol {
    var viewModel: FileViewModelProtocol { get }
}


class DisplayFileUseCase: DisplayFileUseCaseProtocol {
    
    private(set) var viewModel: FileViewModelProtocol = FileViewModel()
    private var file: FileData?
    private let filesUseCase: FilesUseCaseProtocol = FilesUseCase()
    
    init(_ fileId: String?) {
        if let fileId = fileId {
            let file = self.filesUseCase.fileForId(fileId)
            self.file = file
            self.viewModel.delegate = self
            self.viewModel.fileData.onNext((name: file.name, enctype: file.enctype.rawValue, content: file.content))
        }
        self.viewModel.delegate = self
    }
    
}

extension DisplayFileUseCase: FileViewModelDelegate {
    
    func updateAction(_ name: String, _ enctype: String, _ content: String) {
        guard var file = self.file else { return }
        file.name = name
        file.enctype = Enctype(rawValue: enctype)!
        file.content = content
        self.filesUseCase.updateFile(file)
        self.filesUseCase.files.subscribe(onNext: { value in
            self.file = value.first(where: { $0.name == name && $0.enctype.rawValue == enctype })
        }).dispose()
        guard let newFile = self.file else { return }
        self.viewModel.fileData.onNext((name: newFile.name, enctype: newFile.enctype.rawValue, content: newFile.content))
    }
    
    func createAction(_ name: String, _ enctype: String, _ content: String) {
        self.filesUseCase.saveFile(name, Enctype(rawValue: enctype)!, content)
        self.filesUseCase.files.subscribe(onNext: { value in
            self.file = value.first(where: { $0.name == name && $0.enctype.rawValue == enctype })
        }).dispose()
    }
    
    func decryptAction() -> String {
        guard let file = self.file else { return "" }
        let content = self.filesUseCase.decryptFile(file)
        return content
    }
    
}
