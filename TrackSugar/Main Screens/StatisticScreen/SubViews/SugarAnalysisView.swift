import UIKit
import SnapKit

final class SugarAnalysisView: UIView {
    
    private lazy var analysisTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Аналитика сахара"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        return button
    }()
    
    private lazy var patternIcon: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var patternLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var trendIcon: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trendLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var riskView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var riskIcon: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var riskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var adviceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var adviceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Рекомендации:"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(analysisTitleLabel)
        addSubview(infoButton)
        addSubview(patternIcon)
        addSubview(patternLabel)
        addSubview(trendIcon)
        addSubview(trendLabel)
        addSubview(riskView)
        riskView.addSubview(riskIcon)
        riskView.addSubview(riskLabel)
        addSubview(adviceTitleLabel)
        addSubview(adviceStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        analysisTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
        }
        
        infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(analysisTitleLabel)
            make.leading.equalTo(analysisTitleLabel.snp.trailing).offset(4)
        }
        
        patternIcon.snp.makeConstraints { make in
            make.top.equalTo(analysisTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }
        
        patternLabel.snp.makeConstraints { make in
            make.centerY.equalTo(patternIcon)
            make.leading.equalTo(patternIcon.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        trendIcon.snp.makeConstraints { make in
            make.top.equalTo(patternIcon.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(22)
        }
        
        trendLabel.snp.makeConstraints { make in
            make.centerY.equalTo(trendIcon)
            make.leading.equalTo(trendIcon.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        riskView.snp.makeConstraints { make in
            make.top.equalTo(trendIcon.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(32)
            make.width.equalTo(160)
        }
        
        riskIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }
        
        riskLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(riskIcon.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(8)
        }
        
        adviceTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(riskView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
        }
        
        adviceStackView.snp.makeConstraints { make in
            make.top.equalTo(adviceTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }
    
    func updateWithAnalysis(_ analysis: SugarAnalysisResult) {
        updatePatternLabel(analysis.pattern)
        trendLabel.text = analysis.trend
        updateRiskLabel(analysis.riskLevel)
        updateAdviceStack(analysis.advice)
    }
    
    private func updatePatternLabel(_ pattern: SugarPattern) {
        let (patternText, patternEmoji) = patternDescriptionAndIcon(for: pattern)
        patternLabel.text = patternText
        patternIcon.text = patternEmoji
    }
    
    private func updateRiskLabel(_ riskLevel: RiskLevel) {
        let (riskText, riskColor, riskEmoji) = riskDescriptionColorAndIcon(for: riskLevel)
        riskLabel.text = riskText
        riskView.backgroundColor = riskColor
        riskLabel.textColor = .black
        riskIcon.text = riskEmoji
    }
    
    private func updateAdviceStack(_ advice: [SugarAdvice]) {
        adviceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for adviceItem in advice {
            let adviceView = createAdviceView(adviceItem)
            adviceStackView.addArrangedSubview(adviceView)
        }
    }
    
    private func createAdviceView(_ advice: SugarAdvice) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 6
        let icon = UILabel()
        icon.font = UIFont.systemFont(ofSize: 18)
        icon.text = adviceIcon(for: advice.type)
        let title = UILabel()
        title.text = advice.title
        title.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        title.textColor = .black
        let descr = UILabel()
        descr.text = advice.description
        descr.font = UIFont.systemFont(ofSize: 12)
        descr.textColor = .darkGray
        descr.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [icon, title])
        stack.axis = .horizontal
        stack.spacing = 6
        containerView.addSubview(stack)
        containerView.addSubview(descr)
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }
        descr.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
        return containerView
    }
    
    private func adviceIcon(for type: AdviceType) -> String {
        switch type {
        case .preMealInsulin: return "💉"
        case .checkLongInsulin: return "🕒"
        case .adjustMealTiming: return "⏰"
        case .increaseInsulin: return "⬆️"
        case .decreaseInsulin: return "⬇️"
        case .checkBasalRate: return "🔬"
        case .fastingTest: return "🥛"
        case .consultDoctor: return "👨‍⚕️"
        }
    }
    
    private func patternDescriptionAndIcon(for pattern: SugarPattern) -> (String, String) {
        switch pattern {
        case .postMealSpike: return ("Скачок сахара после еды", "🍽️")
        case .fastingRise: return ("Подъем сахара натощак", "🌙")
        case .hypoglycemia: return ("Частые гипогликемии", "⚠️")
        case .stable: return ("Сахар стабилен", "✅")
        case .delayedInsulinEffect: return ("Задержанный эффект инсулина", "⏳")
        case .insufficientInsulin: return ("Недостаточный инсулин", "⬇️")
        case .excessiveInsulin: return ("Избыточный инсулин", "⬆️")
        }
    }
    
    private func trendDescriptionAndIcon(for trend: String) -> (String, String) {
        if trend.contains("повышению") { return ("Тренд: сахар повышается", "⬆️") }
        if trend.contains("снижению") { return ("Тренд: сахар снижается", "⬇️") }
        if trend.contains("стабилен") { return ("Тренд: сахар стабилен", "➖") }
        return (trend, "ℹ️")
    }
    
    private func riskDescriptionColorAndIcon(for risk: RiskLevel) -> (String, UIColor, String) {
        switch risk {
        case .low: return ("Низкий риск", UIColor.green.withAlphaComponent(0.2), "🟢")
        case .medium: return ("Средний риск", UIColor.orange.withAlphaComponent(0.2), "🟠")
        case .high: return ("Высокий риск", UIColor.red.withAlphaComponent(0.2), "🔴")
        case .critical: return ("Критический риск", UIColor.red.withAlphaComponent(0.4), "❗️")
        }
    }
    
    @objc private func showInfo() {
        let alert = UIAlertController(
            title: "Аналитика сахара",
            message: "Этот блок анализирует ваши последние данные и дает советы по управлению диабетом. Советы не заменяют консультацию врача.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        if let vc = self.topViewController() {
            vc.present(alert, animated: true)
        }
    }
    
    // Получить topViewController для корректного показа алерта
    private func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return nil }
        var topController = window.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
}
