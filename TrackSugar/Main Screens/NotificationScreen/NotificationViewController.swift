import UIKit

final class NotificationViewController: UIViewController {

    private let contentView: NotificationView = .init()
    private let viewModel: NotificationViewModelProtocol

    init(viewModel: NotificationViewModelProtocol) {
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
        self.navigationController?.isNavigationBarHidden = true
        contentView.addButtonTapped = { [weak self] in
            self?.navigationController?.pushViewController(
                NotificationConfigViewController(viewModel: NotificationConfigViewModel()),
                animated: true
            )
        }

        contentView.notificationTableView.delegate = self
        contentView.notificationTableView.dataSource = viewModel
        contentView.notificationTableView.register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.reuseIdentifier
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name("updateNotificationDataNotification"), object: nil)
        if viewModel.finishedDataSource.count + viewModel.currentDataSource.count == 0 {
            contentView.showHint()
        } else {
            contentView.notificationTableView.reloadData()
            contentView.hideHint()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollToUpside()
    }

    func addNewNotify(title: String, message: String, date: Date) {
        viewModel.addNewNotify(title: title, message: message, date: date)
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
}
