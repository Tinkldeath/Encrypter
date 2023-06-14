import Foundation


protocol FileRouterProtocol {
    func routeToFilesList()
}


class FileRouter: FileRouterProtocol {
    
    private var view: FileViewProtocol?
    private var useCase: DisplayFileUseCaseProtocol
    
    init(_ view: FileViewProtocol?, _ fileId: String?) {
        self.view = view
        self.useCase = DisplayFileUseCase(fileId)
        self.view?.viewModel = self.useCase.viewModel
    }
    
    func routeToFilesList() {
        self.view?.navigationController?.popViewController(animated: true)
    }
    
}
