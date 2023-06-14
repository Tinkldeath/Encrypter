import Foundation


protocol FilesListRouterProtocol {
    func routeToViewFile(_ id: String)
    func routeToUpdateFile(_ id: String)
    func routeToCreateFile()
}


class FilesListRouter: FilesListRouterProtocol {
    
    private var useCase: DisplayFilesUseCaseProtocol = DisplayFilesUseCase()
    var view: FilesListViewProtocol?
    
    init(_ view: FilesListViewProtocol?) {
        self.view = view
        self.view?.viewModel = self.useCase.viewModel
        self.useCase.displayFiles()
    }
    
    func routeToViewFile(_ id: String) {
        if let vc = self.view?.storyboard?.instantiateViewController(withIdentifier: "FileViewController") as? FileViewController {
            vc.fileId = id
            vc.mode = .view
            self.view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func routeToUpdateFile(_ id: String) {
        if let vc = self.view?.storyboard?.instantiateViewController(withIdentifier: "FileViewController") as? FileViewController {
            vc.fileId = id
            vc.mode = .update
            self.view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func routeToCreateFile() {
        if let vc = self.view?.storyboard?.instantiateViewController(withIdentifier: "FileViewController") as? FileViewController {
            self.view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
