import SnapKit
import UIKit
import DGCharts

final class StatisticView: UIView {

    lazy var contentView: UIView = UIView()
    lazy var timeSegmentControll: UISegmentedControl = UISegmentedControl(items: ["День", "Неделя", "Месяц"])
    lazy var historyTable: UITableView = UITableView()
    lazy var exportButton: UIButton = UIButton(type: .system)
    var chartSubView: ChartSubView
    var sugarStatsSubView: SugarStatsSubView
    var foodStatsSubView: FoodStatsSubView
    var sugarAnalysisView: SugarAnalysisView
    var scrollAddition: CGFloat = 0

    private lazy var statisticLabel: UILabel = UILabel()
    private lazy var sugarLabel: UILabel = UILabel()
    private lazy var averageFoodStatsLabel: UILabel = UILabel()
    private lazy var historyLabel: UILabel = UILabel()
    private lazy var historyHintLabel: UILabel = UILabel()
    private var initialCenterYConstraintConstant: CGFloat = 0
    private var initialTransform = CGAffineTransform.identity
    private var panGestureRecognizer: UIPanGestureRecognizer?

    init(
        frame: CGRect,
        chartData: [ChartDataEntry],
        lowSugar: (Double, SugarState),
        averageSugar: (Double, SugarState),
        highSugar: (Double, SugarState),
        shortInsulinCount: Double,
        breadCount: Double,
        longInsulinCount: Double
    ) {
        self.chartSubView = ChartSubView(frame: .zero, chartData: chartData)
        self.sugarStatsSubView = SugarStatsSubView(frame: .zero, lowSugar: lowSugar, averageSugar: averageSugar, highSugar: highSugar)
        self.foodStatsSubView = FoodStatsSubView(
            frame: .zero,
            shortInsulinCount: shortInsulinCount,
            breadCount: breadCount,
            longInsulinCount: longInsulinCount
        )
        self.sugarAnalysisView = SugarAnalysisView(frame: .zero)
        super.init(frame: frame)
        backgroundColor = .white.withAlphaComponent(0.96)
        setUp()
        if chartData.count == 0 {
            historyTable.isHidden = true
            historyHintLabel.isHidden = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if panGestureRecognizer == nil {
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            guard let panGestureRecognizer else {return}
            contentView.addGestureRecognizer(panGestureRecognizer)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI(
        chartData: [ChartDataEntry],
        sugarStats: (lowSugar: (Double, SugarState), averageSugar: (Double, SugarState), highSugar: (Double, SugarState)),
        foodStats: (shortInsulin: Double, breadCount: Double, longInsulin: Double),
        sugarAnalysis: SugarAnalysisResult
    ) {
        self.chartSubView.updateUI(chartData: chartData)
        sugarStatsSubView.lowSugarView.updateUI(
            countLabel: String(format: "%.1f", sugarStats.lowSugar.0),
            sugarState: sugarStats.lowSugar.1
        )
        sugarStatsSubView.averageSugarView.updateUI(
            countLabel: String(format: "%.1f", sugarStats.averageSugar.0),
            sugarState: sugarStats.averageSugar.1
        )
        sugarStatsSubView.highSugarView.updateUI(
            countLabel: String(format: "%.1f", sugarStats.highSugar.0),
            sugarState: sugarStats.highSugar.1
        )
        foodStatsSubView.shortInsulinStatView.updateUI(countLabel: String(format: "%.1f", foodStats.shortInsulin))
        foodStatsSubView.breadCountStatView.updateUI(countLabel: String(format: "%.1f", foodStats.breadCount))
        foodStatsSubView.longInsulinStatView.updateUI(countLabel: String(format: "%.1f", foodStats.longInsulin))
        sugarAnalysisView.updateWithAnalysis(sugarAnalysis)
        if chartData.count == 0 {
            historyTable.isHidden = true
            historyHintLabel.isHidden = false
        } else {
            historyTable.isHidden = false
            historyHintLabel.isHidden = true
        }
    }

    func scrollToUpside() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.transform = .identity
        }
    }

    func checkExportButtonState() {
        print("Export button frame: \(exportButton.frame)")
        print("Export button isUserInteractionEnabled: \(exportButton.isUserInteractionEnabled)")
        print("Export button alpha: \(exportButton.alpha)")
        print("Export button isHidden: \(exportButton.isHidden)")
    }

    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        chartSubView.updateDataForChart()
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let location = recognizer.location(in: self)
        
        // Проверяем, не находится ли палец на кнопке экспорта
        if exportButton.frame.contains(location) {
            return
        }

        if recognizer.state == .began {
            initialCenterYConstraintConstant = contentView.frame.maxY
            initialTransform = contentView.transform
        } else if recognizer.state == .changed {
            let newMaxY = initialCenterYConstraintConstant + translation.y

            if newMaxY <= 1450 && newMaxY >= 810 + scrollAddition {
                let newTransform = initialTransform.translatedBy(x: 0, y: translation.y)
                contentView.transform = newTransform
            }
        }
    }

    private func setUp() {
        setUpContentView()
        setUpStatisticLabel()
        setUpExportButton()
        setUpTimeSegmentControll()
        setUpChartSubView()
        setUpSugarLabel()
        setUpSugarStatsSubView()
        setUpSugarAnalysisView()
        setUpAverageFoodStatsLabel()
        setUpFoodStatsSubView()
        setUpHistoryLabel()
        setUpHistoryTable()
        setUpHistoryHintLabel()
    }

    private func setUpContentView() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1450)
        }
    }

    private func setUpStatisticLabel() {
        contentView.addSubview(statisticLabel)
        statisticLabel.text = "Статистика"
        statisticLabel.textColor = .black
        statisticLabel.font = UIFont.boldSystemFont(ofSize: 24)
        statisticLabel.textAlignment = .center

        statisticLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70)
            make.width.equalTo(150)
        }
    }

    private func setUpExportButton() {
        contentView.addSubview(exportButton)
        exportButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        exportButton.tintColor = .mainApp
        exportButton.backgroundColor = .clear
        exportButton.layer.zPosition = 1000
        
        exportButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(70)
            make.width.height.equalTo(50)
        }
    }

    private func setUpTimeSegmentControll() {
        contentView.addSubview(timeSegmentControll)
        timeSegmentControll.selectedSegmentIndex = 0
        timeSegmentControll.tintColor = .mainApp

        let font = UIFont.systemFont(ofSize: 16)
        timeSegmentControll.selectedSegmentTintColor = .mainApp
        timeSegmentControll.setTitleTextAttributes([.foregroundColor: UIColor.mainApp, .font: font], for: .normal)
        timeSegmentControll.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: font], for: .selected)
        timeSegmentControll.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        timeSegmentControll.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statisticLabel.snp.bottom).offset(20)
        }
    }

    private func setUpChartSubView() {
        contentView.addSubview(chartSubView)
        chartSubView.snp.makeConstraints { make in
            make.top.equalTo(timeSegmentControll.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(270)
        }
    }

    private func setUpSugarLabel() {
        contentView.addSubview(sugarLabel)
        sugarLabel.text = "Сахар"
        sugarLabel.textColor = .black
        sugarLabel.font = UIFont.boldSystemFont(ofSize: 16)

        sugarLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(chartSubView.snp.bottom).offset(20)
        }
    }

    private func setUpSugarStatsSubView() {
        contentView.addSubview(sugarStatsSubView)
        sugarStatsSubView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(38)
            make.trailing.equalToSuperview().inset(38)
            make.height.equalTo(115)
            make.top.equalTo(sugarLabel.snp.bottom).offset(15)
        }
    }

    private func setUpSugarAnalysisView() {
        contentView.addSubview(sugarAnalysisView)
        sugarAnalysisView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(sugarStatsSubView.snp.bottom).offset(20)
            make.height.equalTo(250)
        }
    }

    private func setUpAverageFoodStatsLabel() {
        contentView.addSubview(averageFoodStatsLabel)
        averageFoodStatsLabel.text = "Средние показатели"
        averageFoodStatsLabel.textColor = .black
        averageFoodStatsLabel.font = UIFont.boldSystemFont(ofSize: 16)

        averageFoodStatsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(sugarAnalysisView.snp.bottom).offset(20)
        }
    }

    private func setUpFoodStatsSubView() {
        contentView.addSubview(foodStatsSubView)
        foodStatsSubView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(145)
            make.top.equalTo(averageFoodStatsLabel.snp.bottom).offset(15)
        }
    }

    private func setUpHistoryLabel() {
        contentView.addSubview(historyLabel)
        historyLabel.text = "История"
        historyLabel.textColor = .black
        historyLabel.font = UIFont.boldSystemFont(ofSize: 16)

        historyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(foodStatsSubView.snp.bottom).offset(20)
        }
    }

    private func setUpHistoryTable() {
        contentView.addSubview(historyTable)
        historyTable.showsVerticalScrollIndicator = false
        historyTable.separatorColor = .clear
        historyTable.backgroundColor = .clear
        historyTable.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
            make.top.equalTo(historyLabel.snp.bottom).offset(15)
            make.bottom.equalToSuperview()
        }
    }

    private func setUpHistoryHintLabel() {
        contentView.addSubview(historyHintLabel)
        historyHintLabel.text = "У вас пока нет добавленных записей"
        historyHintLabel.textColor = .lightGray
        historyHintLabel.numberOfLines = 2
        historyHintLabel.lineBreakMode = .byWordWrapping
        historyHintLabel.textAlignment = .center
        historyHintLabel.font = UIFont.systemFont(ofSize: 24)
        historyHintLabel.isHidden = true

        historyHintLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
            make.top.equalTo(historyLabel.snp.bottom).offset(15)
        }
    }
}
