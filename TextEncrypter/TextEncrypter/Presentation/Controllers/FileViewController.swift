import UIKit
import RxSwift


protocol FileViewProtocol: AnyObject & UIViewController {
    var fileId: String? { get set }
    var viewModel: FileViewModelProtocol! { get set }
}


class FileViewController: UIViewController, FileViewProtocol {
    
    @IBOutlet var controlButton: UIBarButtonItem!
    @IBOutlet var fileNameTextField: UITextField!
    @IBOutlet var enctypeSegmentedControl: UISegmentedControl!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var textView: UITextView!
    
    private var router: FileRouterProtocol!
    private let disposeBag = DisposeBag()
    
    var viewModel: FileViewModelProtocol!
    var fileId: String? = nil
    var previousContent: String = ""
    
    var mode: Mode = .create

    override func viewDidLoad() {
        super.viewDidLoad()
        self.router = FileRouter(self, self.fileId)
        self.setup()
    }
    
    @IBAction func didClickControlButton(_ sender: UIBarButtonItem) {
        switch self.mode {
        case .view:
            self.mode = .update
            self.didChangeMode()
        case .update:
            self.updateAction()
            self.didChangeMode()
        case .create:
            self.createAction()
            self.didChangeMode()
        }
    }
    
    @IBAction func didClickBack(_ sender: UIBarButtonItem) {
        self.router.routeToFilesList()
    }
    
    private func setup() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(recognizer)
        self.drawTextView()
        self.bindFile()
        self.didChangeMode()
    }
    
    private func drawTextView() {
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.cornerRadius = 10
    }
    
    private func bindFile() {
        self.viewModel.fileData.subscribe(onNext: { [weak self] value in
            self?.navigationItem.title = value.name
            self?.fileNameTextField.text = value.name
            self?.textView.text = value.content
            self?.previousContent = value.content
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func didTouchEye(_ sender: UIButton) {
        if sender.tag == 0 {
            self.viewDecryptedAction()
        } else {
            self.viewEncrypted()
        }
    }
    
    @objc private func dismissKeyboard() {
        self.textView.resignFirstResponder()
    }
    
    private func didChangeMode() {
        self.fileNameTextField.isHidden = self.mode != .create && self.mode != .update
        self.enctypeSegmentedControl.isHidden = self.mode != .create && self.mode != .update
        self.viewButton.isHidden = self.mode == .create || self.mode == .update
        switch self.mode {
        case .view:
            self.controlButton.title = "Edit"
            self.textView.isEditable = false
        case .update:
            self.textView.text = self.viewModel.decryptedView()
            self.fileNameTextField.isEnabled = false
            self.controlButton.title = "Save"
            self.textView.isEditable = true
        default:
            self.fileNameTextField.isEnabled = true
            self.controlButton.title = "Save"
            self.textView.isEditable = true
        }
    }
    
    private func viewDecryptedAction() {
        let decrypted = self.viewModel.decryptedView()
        self.textView.text = decrypted
        self.viewButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        self.viewButton.tag = 1
    }
    
    private func viewEncrypted() {
        self.textView.text = self.previousContent
        self.viewButton.setImage(UIImage(systemName: "eye"), for: .normal)
        self.viewButton.tag = 0
    }
    
    private func updateAction() {
        guard self.fileNameTextField.text != "" else { return }
        guard self.textView.text != "" else { return }
        guard let enctype = self.enctypeSegmentedControl.titleForSegment(at: self.enctypeSegmentedControl.selectedSegmentIndex) else { return }
        self.viewModel.update(self.fileNameTextField.text!, enctype, self.textView.text)
        self.presentAlert("Successfully updated")
        self.mode = .view
    }
    
    private func createAction() {
        guard self.fileNameTextField.text != "" else { return }
        guard self.textView.text != "" else { return }
        guard let enctype = self.enctypeSegmentedControl.titleForSegment(at: self.enctypeSegmentedControl.selectedSegmentIndex) else { return }
        self.viewModel.create(self.fileNameTextField.text!, enctype, self.textView.text)
        self.presentAlert("Successfully created")
        self.mode = .view
    }
    
    private func presentAlert(_ message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(ac, animated: true)
    }
    
}

extension FileViewController {
    
    enum Mode {
        case create, update, view
    }
    
}
