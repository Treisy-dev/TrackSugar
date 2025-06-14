import UIKit

final class NameRegisterViewController: UIViewController {

    private let contentView: NameRegisterView = .init()

    private let viewModel: NameRegisterViewModelProtocol

    var onFinish: (() -> Void)?

    init(viewModel: NameRegisterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.delegate = self
        contentView.showAlert = { [weak self] in
            let alert = UIAlertController(
                title: "Предупреждение",
                message: "Пожалуйста, заполните все поля",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

extension NameRegisterViewController: NameRegisterViewDelegate {

    func didPressNext(name: String?, email: String?) {
        viewModel.saveUserInfo(name: name, email: email)
        onFinish?()
    }
}
