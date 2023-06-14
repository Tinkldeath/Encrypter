import UIKit
import RxSwift
import RxCocoa


protocol FilesListViewProtocol: AnyObject & UIViewController {
    var viewModel: FilesListViewModelProtocol! { get set }
}


class FilesListViewController: UIViewController, FilesListViewProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let reuseIdentifier = "FileCell"
    private let disposeBag = DisposeBag()
    private var router: FilesListRouterProtocol!
    
    var viewModel: FilesListViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetch()
    }
    
    private func setup() {
        self.router = FilesListRouter(self)
        self.bindTableView()
        self.bindFileSelection()
    }
    
    @IBAction func didClickAddButton(_ sender: Any) {
        self.router.routeToCreateFile()
    }
    
    private func bindTableView() {
        self.viewModel.fileData.bind(to: self.tableView.rx.items(cellIdentifier: self.reuseIdentifier)) { _, item, cell in
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.enctype
        }.disposed(by: self.disposeBag)
        self.tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.viewModel.didClickFileAtIndex(indexPath.row)
        }).disposed(by: self.disposeBag)
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
    private func bindFileSelection() {
        self.viewModel.selectedFile.subscribe(onNext: { [weak self] data in
            guard let data = data else { return }
            if data.edit {
                self?.router.routeToUpdateFile(data.id)
            } else {
                self?.router.routeToViewFile(data.id)
            }
        }).disposed(by: self.disposeBag)
    }
    
}

extension FilesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .normal, title: "Edit", handler: { [weak self] _, _, _ in
                self?.viewModel.didClickEditFileAtIndex(indexPath.row)
            })
        ])
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] _, _, _ in
                self?.viewModel.didClickDeleteFileAtIndex(indexPath.row)
            })
        ])
        return config
    }
    
}
