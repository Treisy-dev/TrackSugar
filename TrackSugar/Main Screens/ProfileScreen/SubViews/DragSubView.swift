import SnapKit
import UIKit

final class DragSubView: UIView {

    let preferencesHSFabric: PreferencesHStackFabricProtocol

    private lazy var dragVStack: UIStackView = UIStackView()
    private lazy var dragLable: UILabel = UILabel()

    private lazy var underlineView: CustomUnderlineView = CustomUnderlineView(
        frame: CGRect(x: 0, y: 0, width: 300, height: 1))

    init(
        frame: CGRect,
        shortInsulin: String,
        longInsulin: String,
        preferenceHStackFabric: PreferencesHStackFabricProtocol) {
        preferencesHSFabric = preferenceHStackFabric
        super.init(frame: frame)
        setUpDragVStack(
            shortInsulin: shortInsulin,
            longInsulin: longInsulin)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpDragVStack(
        shortInsulin: String,
        longInsulin: String) {
            addSubview(dragVStack)
            dragVStack.axis = .vertical
            dragVStack.spacing = 15

            dragLable.text = "Инсулины:"
            dragLable.font = UIFont.systemFont(ofSize: 16)
            dragLable.textColor = .black

            dragVStack.addArrangedSubview(dragLable)
            dragVStack.addArrangedSubview(preferencesHSFabric.makeHStackWithIcon(
            withLabel: " Короткий инсулин",
            withImage: UIImage.shortInsulinIcon,
            withCountLable: nil,
            coloredText: shortInsulin))
            dragVStack.addArrangedSubview(preferencesHSFabric.makeHStackWithIcon(
            withLabel: "Длинный инсулин",
            withImage: UIImage.longInsulinIcon,
            withCountLable: nil,
            coloredText: longInsulin))

            dragVStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            }
            addSubview(underlineView)
            underlineView.snp.makeConstraints { make in
                make.top.equalTo(dragVStack.snp_bottomMargin).offset(20)
                make.leading.equalTo(dragVStack.snp_leadingMargin)
            }
    }
}
