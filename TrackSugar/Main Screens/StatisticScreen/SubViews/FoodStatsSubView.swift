import SnapKit
import UIKit

final class FoodStatsSubView: UIView {

    var shortInsulinStatView: CustomFoodStatisticView
    var breadCountStatView: CustomFoodStatisticView
    var longInsulinStatView: CustomFoodStatisticView

    private lazy var foodStatsHStack: UIStackView = UIStackView()

    init(frame: CGRect, shortInsulinCount: Double, breadCount: Double, longInsulinCount: Double) {
        self.shortInsulinStatView = CustomFoodStatisticView(
            frame: .zero,
            countLabel: String(format: "%.1f", shortInsulinCount),
            titleLabel: "Короткий инсулин"
        )
        self.breadCountStatView = CustomFoodStatisticView(
            frame: .zero,
            countLabel: String(format: "%.1f", breadCount),
            titleLabel: "Хлебные единицы"
        )
        self.longInsulinStatView = CustomFoodStatisticView(
            frame: .zero,
            countLabel: String(format: "%.1f", longInsulinCount),
            titleLabel: "Длинный инсулин"
        )
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        setUpFoodStatsHStack()
    }

    private func setUpFoodStatsHStack() {
        addSubview(foodStatsHStack)
        foodStatsHStack.axis = .horizontal
        foodStatsHStack.distribution = .equalSpacing
        foodStatsHStack.backgroundColor = .clear

        foodStatsHStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setUpShortInsulinStatView()
        setUpBreadCountStatView()
        setUpLongInsulinStatView()
    }

    private func setUpShortInsulinStatView() {
        foodStatsHStack.addArrangedSubview(shortInsulinStatView)
        shortInsulinStatView.snp.makeConstraints { make in
            make.width.equalTo(96)
            make.top.bottom.equalToSuperview()
        }
    }

    private func setUpBreadCountStatView() {
        foodStatsHStack.addArrangedSubview(breadCountStatView)
        breadCountStatView.snp.makeConstraints { make in
            make.width.equalTo(96)
            make.top.bottom.equalToSuperview()
        }
    }

    private func setUpLongInsulinStatView() {
        foodStatsHStack.addArrangedSubview(longInsulinStatView)
        longInsulinStatView.snp.makeConstraints { make in
            make.width.equalTo(96)
            make.top.bottom.equalToSuperview()
        }
    }
}
