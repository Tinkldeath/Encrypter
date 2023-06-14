import Foundation
import RxSwift


typealias DetailedFileViewModel = (name: String, enctype: String, content: String)


protocol FileViewModelProtocol {
    
    var fileData: BehaviorSubject<DetailedFileViewModel> { get }
    var delegate: FileViewModelDelegate? { get set }
    
    func decryptedView() -> String
    func update(_ name: String, _ enctype: String, _ content: String)
    func create(_ name: String, _ enctype: String, _ content: String)
    
}

protocol FileViewModelDelegate {
    
    func updateAction(_ name: String, _ enctype: String, _ content: String)
    func createAction(_ name: String, _ enctype: String, _ content: String)
    func decryptAction() -> String
    
}


class FileViewModel: FileViewModelProtocol {
    
    private(set) var fileData: BehaviorSubject<DetailedFileViewModel> = BehaviorSubject(value: ("", Enctype.aes.rawValue, ""))
    var delegate: FileViewModelDelegate?
    
    func decryptedView() -> String {
        return self.delegate?.decryptAction() ?? ""
    }
    
    func update(_ name: String, _ enctype: String, _ content: String) {
        self.delegate?.updateAction(name, enctype, content)
    }
    
    func create(_ name: String, _ enctype: String, _ content: String) {
        self.delegate?.createAction(name, enctype, content)
    }
    
}
