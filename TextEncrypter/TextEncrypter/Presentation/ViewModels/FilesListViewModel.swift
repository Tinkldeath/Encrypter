import Foundation
import RxSwift


typealias FileDataViewModel = (name: String, enctype: String)
typealias SelectedFileDataViewModel = (id: String, edit: Bool)


protocol FilesListViewModelProtocol {

    var fileData: BehaviorSubject<[FileDataViewModel]> { get }
    var selectedFile: BehaviorSubject<SelectedFileDataViewModel?> { get }
    
    var delegate: FilesListViewModelDelegate? { get set }
    
    func fetch()
    func didClickFileAtIndex(_ index: Int)
    func didClickEditFileAtIndex(_ index: Int)
    func didClickDeleteFileAtIndex(_ index: Int)
    
}

protocol FilesListViewModelDelegate {
    
    func update()
    func selectActionAtIndex(_ index: Int)
    func editActionAtIndex(_ index: Int)
    func deleteActionAtIndex(_ index: Int)
    
}


class FilesListViewModel: FilesListViewModelProtocol {
    
    private(set) var fileData: BehaviorSubject<[FileDataViewModel]> = BehaviorSubject(value: [])
    private(set) var selectedFile: BehaviorSubject<SelectedFileDataViewModel?> = BehaviorSubject(value: nil)
    var delegate: FilesListViewModelDelegate?
    
    func fetch() {
        self.delegate?.update()
    }
    
    func didClickFileAtIndex(_ index: Int) {
        self.delegate?.selectActionAtIndex(index)
    }
    
    func didClickEditFileAtIndex(_ index: Int) {
        self.delegate?.editActionAtIndex(index)
    }
    
    func didClickDeleteFileAtIndex(_ index: Int) {
        self.delegate?.deleteActionAtIndex(index)
    }
    
}
