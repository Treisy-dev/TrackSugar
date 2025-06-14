import SnapKit
import UIKit

final class NewNotePhysicalActivitySubView: UIView {
    
    lazy var activitySegmentedControl: UISegmentedControl = UISegmentedControl()
    
    private lazy var activityLabel: UILabel = UILabel()
    private lazy var hintLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray.withAlphaComponent(0.15)
        self.layer.cornerRadius = 18
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpActivityLabel()
        setUpActivitySegmentedControl()
        setUpHintLabel()
    }
    
    private func setUpActivityLabel() {
        addSubview(activityLabel)
        activityLabel.text = "Физическая активность"
        activityLabel.font = UIFont.boldSystemFont(ofSize: 16)
        activityLabel.textColor = .black
        activityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
    }
    
    private func setUpActivitySegmentedControl() {
        addSubview(activitySegmentedControl)
        
        // Настройка сегментов
        activitySegmentedControl.insertSegment(withTitle: "Нет", at: 0, animated: false)
        activitySegmentedControl.insertSegment(withTitle: "Легкая", at: 1, animated: false)
        activitySegmentedControl.insertSegment(withTitle: "Средняя", at: 2, animated: false)
        activitySegmentedControl.insertSegment(withTitle: "Интенсивная", at: 3, animated: false)
        
        // Настройка внешнего вида
        activitySegmentedControl.selectedSegmentIndex = 0
        activitySegmentedControl.tintColor = .mainApp
        activitySegmentedControl.selectedSegmentTintColor = .mainApp
        
        let font = UIFont.systemFont(ofSize: 14)
        activitySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.mainApp, .font: font], for: .normal)
        activitySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: font], for: .selected)
        
        activitySegmentedControl.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(activityLabel.snp.bottom).offset(15)
            make.height.equalTo(35)
        }
    }
    
    private func setUpHintLabel() {
        addSubview(hintLabel)
        hintLabel.text = "Выберите уровень активности"
        hintLabel.font = UIFont.systemFont(ofSize: 13)
        hintLabel.textColor = .lightGray.withAlphaComponent(0.8)
        hintLabel.textAlignment = .center
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(activitySegmentedControl.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    // MARK: - Public Methods
    
    func getSelectedActivity() -> String {
        switch activitySegmentedControl.selectedSegmentIndex {
        case 0: return "Нет"
        case 1: return "Легкая"
        case 2: return "Средняя"
        case 3: return "Интенсивная"
        default: return "Нет"
        }
    }
    
    func setSelectedActivity(_ activity: String) {
        switch activity {
        case "Нет": activitySegmentedControl.selectedSegmentIndex = 0
        case "Легкая": activitySegmentedControl.selectedSegmentIndex = 1
        case "Средняя": activitySegmentedControl.selectedSegmentIndex = 2
        case "Интенсивная": activitySegmentedControl.selectedSegmentIndex = 3
        default: activitySegmentedControl.selectedSegmentIndex = 0
        }
    }
} 
