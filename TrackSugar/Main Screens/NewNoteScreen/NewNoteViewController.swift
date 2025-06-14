import UIKit

final class NewNoteViewController: UIViewController {

    private let contentView: NewNoteView

    var viewModel: NewNoteViewModelProtocol
    var onFinish: (() -> Void)?

    init(viewModel: NewNoteViewModelProtocol) {
        self.viewModel = viewModel
        contentView = NewNoteView(frame: CGRect(), averageSugar: viewModel.averageSugar)
        super.init(nibName: nil, bundle: nil)
        contentView.injectionSubView.breadTextField.delegate = self
        contentView.injectionSubView.shortInsulinTextField.delegate = self
        contentView.injectionSubView.longInsulinTextField.delegate = self
        navigationController?.isNavigationBarHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.foodSubView.foodtableView.delegate = self
        contentView.foodSubView.foodtableView.dataSource = viewModel
        contentView.panGestureRecognizer?.delegate = self

        contentView.saveTapped = { [weak self] in
            self?.viewModel.saveNewNote(
                breadCount: self?.contentView.injectionSubView.breadTextField.text ?? "0.0",
                sugar: self?.contentView.sugarSubView.sugarCountLabel.text ?? "5.5",
                shortInsulin: self?.contentView.injectionSubView.shortInsulinTextField.text ?? "0.0",
                longInsulin: self?.contentView.injectionSubView.longInsulinTextField.text ?? "0.0",
                physicalActivity: self?.contentView.physicalActivitySubView.getSelectedActivity() ?? "Нет"
            )

            self?.resetChanges()
            self?.updateContentViewLayout()
            self?.contentView.scrollToUpside()

            let alert = UIAlertController(title: "Запись добавлена!", message: "Вы добавили запись", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }

        contentView.foodSubView.addProductTapped = { [weak self] in
            self?.onFinish?()
        }

        contentView.resetTapped = { [weak self] in
            self?.resetChanges()
            self?.updateContentViewLayout()
            self?.contentView.scrollToUpside()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContentViewLayout()
        changeInjectionStats()
        contentView.scrollToUpside()
    }

    private func resetChanges() {
        NotificationCenter.default.post(name: Notification.Name("resetNoteChangesNotification"), object: nil)
        contentView.injectionSubView.breadTextField.text = "0"
        contentView.injectionSubView.shortInsulinTextField.text = "0"
        contentView.injectionSubView.longInsulinTextField.text = "0"
        contentView.injectionSubView.breadSlider.value = 0
        contentView.injectionSubView.shortInsulinSlider.value = 0
        contentView.injectionSubView.longInsulinSlider.value = 0
        contentView.sugarSubView.sugarCountLabel.text = viewModel.getAverageSugar()
        contentView.physicalActivitySubView.setSelectedActivity("Нет")
    }

    private func updateContentViewLayout() {
        contentView.foodSubView.snp.updateConstraints { make in
            make.height.equalTo(140 + 70 * CGFloat(Float(viewModel.userProducts.count)))
        }
        contentView.newNoteContentView.snp.updateConstraints { make in
            make.height.equalTo(950 + 70 * CGFloat(Float(viewModel.userProducts.count)))
        }
        contentView.scrollAddition = 70 * CGFloat(Float(viewModel.userProducts.count))
        contentView.layoutIfNeeded()
        contentView.foodSubView.foodtableView.reloadData()
    }

    private func changeInjectionStats() {
        guard let breadCountFloat = Float(viewModel.getBreadCount()),
            let insulinCountFloat = Float(viewModel.getInsulinCount()) else { return }
        contentView.injectionSubView.breadTextField.text = viewModel.getBreadCount()
        contentView.injectionSubView.breadSlider.value = breadCountFloat
        contentView.injectionSubView.shortInsulinTextField.text = viewModel.getInsulinCount()
        contentView.injectionSubView.shortInsulinSlider.value = insulinCountFloat
    }
}

extension NewNoteViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(textField)
    }
}

extension NewNoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        updateContentViewLayout()
    }
}

extension NewNoteViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: contentView)
        
        // Не обрабатываем gesture на кнопках
        if contentView.resetButton.frame.contains(location) || contentView.saveButton.frame.contains(location) {
            return false
        }
        
        // Не обрабатываем gesture на sugarSubView
        let sugarLocation = touch.location(in: contentView.sugarSubView)
        if contentView.sugarSubView.sugarView.frame.contains(sugarLocation) {
            return false
        }
        
        return true
    }
}
