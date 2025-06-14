import SnapKit
import UIKit

final class CustomCircledView: UIView {

    lazy var countLabel: UILabel = UILabel()

    init(frame: CGRect, color: UIColor, count: String) {
        super.init(frame: frame)
        setUp()
        layer.borderColor = color.cgColor
        countLabel.textColor = color
        countLabel.text = count
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        setUpView()
        setUpSugarCountLabel()
    }

    private func setUpView() {
        layer.cornerRadius = 25
        layer.borderWidth = 2
    }

    private func setUpSugarCountLabel() {
        addSubview(countLabel)
        countLabel.font = UIFont.boldSystemFont(ofSize: 20)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.8
        countLabel.textAlignment = .center

        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().inset(2)
        }
    }
}
