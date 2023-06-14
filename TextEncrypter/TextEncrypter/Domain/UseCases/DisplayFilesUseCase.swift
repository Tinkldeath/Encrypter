import Foundation
import RxSwift


protocol DisplayFilesUseCaseProtocol {
    
    var viewModel: FilesListViewModelProtocol { get }
    
    func displayFiles()
    func displayFile(_ file: FileData)
    func displayEditFile(_ file: FileData)
    
}


class DisplayFilesUseCase {
    
    private let filesUseCase: FilesUseCaseProtocol
    private let disposeBag = DisposeBag()
    private(set) var viewModel: FilesListViewModelProtocol
    private var files: [FileData] = []
    
    init() {
        self.filesUseCase = FilesUseCase()
        self.viewModel = FilesListViewModel()
        self.viewModel.delegate = self
    }
    
}

extension DisplayFilesUseCase: DisplayFilesUseCaseProtocol {
    
    func displayFiles() {
        self.filesUseCase.files.subscribe(onNext: { [weak self] value in
            self?.files = value
            self?.viewModel.fileData.onNext(value.map({ ($0.name, $0.enctype.rawValue) }))
        }).disposed(by: self.disposeBag)
        self.filesUseCase.getFiles()
    }
    
    func displayEditFile(_ file: FileData) {
        self.viewModel.selectedFile.onNext((file.id, true))
    }
    
    func displayFile(_ file: FileData) {
        self.viewModel.selectedFile.onNext((file.id, false))
    }
    
}

extension DisplayFilesUseCase: FilesListViewModelDelegate {
    
    func update() {
        self.displayFiles()
    }
    
    func selectActionAtIndex(_ index: Int) {
        let file = self.files[index]
        self.displayFile(file)
    }
    
    func editActionAtIndex(_ index: Int) {
        let file = self.files[index]
        self.displayEditFile(file)
    }
    
    func deleteActionAtIndex(_ index: Int) {
        let file = self.files[index]
        self.filesUseCase.deleteFile(file)
    }
    
}
