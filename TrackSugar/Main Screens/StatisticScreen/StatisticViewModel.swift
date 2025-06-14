import UIKit
import DGCharts
import Combine
import Foundation

protocol StatisticViewModelProtocol: UITableViewDataSource {
    var dataSource: [NotesHistory] { get }

    func getSugarHistoryDay(startDate: Date, endDate: Date) -> [ChartDataEntry]
    func getSugarHistoryWeek(startDate: Date, endDate: Date) -> [ChartDataEntry]
    func getMinimalSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState)
    func getAverageSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState)
    func getMaximalSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState)
    func getBreadCountBy(startDate: Date, endDate: Date) -> Double
    func getShortInsulinBy(startDate: Date, endDate: Date) -> Double
    func getLongInsulinBy(startDate: Date, endDate: Date) -> Double
    func updateDataSource(startDate: Date, endDate: Date)
    func exportToCSV() -> URL?
    func getSugarAnalysis() -> SugarAnalysisResult
}

final class StatisticViewModel: NSObject, StatisticViewModelProtocol {
    var coreDataManager: CoreDataManagerProtocol
    var userDefaultsDataManager: UserDefaultsDataManagerProtocol
    var sugarAnalysisManager: SugarAnalysisManagerProtocol
    var dataSource: [NotesHistory] = []

    init(coreDM: CoreDataManagerProtocol, userDefaultsDM: UserDefaultsDataManagerProtocol, sugarAnalysisManager: SugarAnalysisManagerProtocol) {
        coreDataManager = coreDM
        userDefaultsDataManager = userDefaultsDM
        self.sugarAnalysisManager = sugarAnalysisManager
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationReceived),
            name: Notification.Name("updateStatisticDataNotification"),
            object: nil
        )
        // Инициализируем данные для текущего дня
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
        updateTableDataSource(startDate: startDate, endDate: endDate)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateStatisticDataNotification"), object: nil)
    }

    @objc func notificationReceived(_ notification: Notification) {
        guard let datePair = notification.object as? (Date, Date) else { return }
        updateTableDataSource(startDate: datePair.0, endDate: datePair.1)
    }

    func getSugarHistoryDay(startDate: Date, endDate: Date) -> [ChartDataEntry] {
        let sugarData = coreDataManager.obtainAllSugarWithDateHistory(from: startDate, to: endDate)

        var chartDataEntryArray: [ChartDataEntry] = []
        for (sugarValue, date) in sugarData {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour], from: date)
            let hour = components.hour ?? 0

            let chartDataEntry = ChartDataEntry(x: Double(hour), y: Double(sugarValue))
            chartDataEntryArray.append(chartDataEntry)
        }

        return chartDataEntryArray
    }

    func getSugarHistoryWeek(startDate: Date, endDate: Date) -> [ChartDataEntry] {
        let sugarData = coreDataManager.obtainAllSugarWithDateHistory(from: startDate, to: endDate)

        var sugarValuesPerDay: [Int: [Double]] = [:]

        for (sugarValue, date) in sugarData {
            let day = Calendar.current.dateComponents([.day], from: date).day ?? 0
            sugarValuesPerDay[day, default: []].append(sugarValue)
        }

        var chartDataEntryArray: [ChartDataEntry] = []

        for (day, sugarValues) in sugarValuesPerDay {
            let averageSugarValue = sugarValues.reduce(0, { $0 + $1 }) / Double(sugarValues.count)
            let chartDataEntry = ChartDataEntry(x: Double(day), y: averageSugarValue)
            chartDataEntryArray.append(chartDataEntry)
        }

        return chartDataEntryArray
    }

    func getMinimalSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState) {
        var sugarData = coreDataManager.obtainAllSugarWithDateHistory(from: startDate, to: endDate)
        sugarData.sort { $0.0 < $1.0 }
        guard let minimalSugar = sugarData.first?.0 else { return (0, .normal) }
        guard let target = Double(userDefaultsDataManager.getLowTarget()) else { return (0, .normal) }

        return (minimalSugar, getMinimalSugarState(target: target, value: minimalSugar))
    }

    func getAverageSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState) {
        let sugarData = coreDataManager.obtainAllSugarWithDateHistory(from: startDate, to: endDate)
        if sugarData.count == 0 {
            return (0, .normal)
        }
        let averageSugarValue = Double(sugarData.reduce(0, { $0 + $1.0 })) / Double(sugarData.count)
        guard let target = Double(userDefaultsDataManager.getAverageTarget()) else { return (0, .normal) }

        return (averageSugarValue, getAverageSugarState(target: target, value: averageSugarValue))
    }

    func getMaximalSugarBy(startDate: Date, endDate: Date) -> (Double, SugarState) {
        var sugarData = coreDataManager.obtainAllSugarWithDateHistory(from: startDate, to: endDate)
        sugarData.sort { $0.0 < $1.0 }
        guard let maximalSugar = sugarData.last?.0 else { return (0, .normal) }
        guard let target = Double(userDefaultsDataManager.getHighTarget()) else { return (0, .normal) }

        return (maximalSugar, getMaximalSugarState(target: target, value: maximalSugar))
    }

    func getBreadCountBy(startDate: Date, endDate: Date) -> Double {
        return coreDataManager.obtainBreadCountBy(from: startDate, to: endDate)
    }

    func getShortInsulinBy(startDate: Date, endDate: Date) -> Double {
        return coreDataManager.obtainShortInsulinCountBy(from: startDate, to: endDate)
    }

    func getLongInsulinBy(startDate: Date, endDate: Date) -> Double {
        return coreDataManager.obtainLongInsulinCountBy(from: startDate, to: endDate)
    }

    func exportToCSV() -> URL? {
        guard !dataSource.isEmpty else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        var csvString = "Дата и время,Сахар крови (ммоль/л),Хлебные единицы (ХЕ),Короткий инсулин (ед),Длинный инсулин (ед),Физическая активность\n"
        
        for record in dataSource.sorted(by: { $0.date > $1.date }) {
            let dateString = dateFormatter.string(from: record.date)
            let sugarString = String(format: "%.1f", record.sugar)
            let breadString = String(format: "%.1f", record.breadCount)
            let shortInsulinString = String(format: "%.1f", record.shortInsulin)
            let longInsulinString = String(format: "%.1f", record.longInsulin)
            let activityString = record.physicalActivity ?? "Нет"
            
            csvString += "\(dateString),\(sugarString),\(breadString),\(shortInsulinString),\(longInsulinString),\(activityString)\n"
        }
        
        // --- Добавляем отчет алгоритма ---
        let analysis = getSugarAnalysis()
        csvString += "\n--- Аналитика алгоритма ---\n"
        csvString += "Паттерн: \(patternDescription(for: analysis.pattern))\n"
        csvString += "Тренд: \(analysis.trend)\n"
        csvString += "Риск: \(riskDescription(for: analysis.riskLevel))\n"
        if !analysis.advice.isEmpty {
            csvString += "Рекомендации:\n"
            for advice in analysis.advice {
                csvString += "- \(advice.title): \(advice.description)\n"
            }
        }
        // --- Конец отчета ---
        
        // Создаем временный файл
        let fileName = "TrackSugar_Export_\(Date().timeIntervalSince1970).csv"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Ошибка при создании CSV файла: \(error)")
            return nil
        }
    }

    // Вспомогательные функции для описания паттерна и риска
    private func patternDescription(for pattern: SugarPattern) -> String {
        switch pattern {
        case .postMealSpike: return "Скачок сахара после еды"
        case .fastingRise: return "Подъем сахара натощак"
        case .hypoglycemia: return "Частые гипогликемии"
        case .stable: return "Сахар стабилен"
        case .delayedInsulinEffect: return "Задержанный эффект инсулина"
        case .insufficientInsulin: return "Недостаточный инсулин"
        case .excessiveInsulin: return "Избыточный инсулин"
        }
    }
    private func riskDescription(for risk: RiskLevel) -> String {
        switch risk {
        case .low: return "Низкий риск"
        case .medium: return "Средний риск"
        case .high: return "Высокий риск"
        case .critical: return "Критический риск"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HistoryTableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none

        let date = dataSource[indexPath.row].date
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedTime = timeFormatter.string(from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        let formattedDate = dateFormatter.string(from: date)

        cell.config(
            date: (formattedDate, formattedTime),
            bloodCount: String(dataSource[indexPath.row].sugar),
            breadCount: String(dataSource[indexPath.row].breadCount),
            insulinCount: String(dataSource[indexPath.row].shortInsulin),
            longInsulinCount: String(dataSource[indexPath.row].longInsulin),
            physicalActivity: dataSource[indexPath.row].physicalActivity ?? "Нет"
        )
        return cell
    }

    private func updateTableDataSource(startDate: Date, endDate: Date) {
        dataSource = coreDataManager.obtainHistoryBy(from: startDate, to: endDate)
    }

    func updateDataSource(startDate: Date, endDate: Date) {
        updateTableDataSource(startDate: startDate, endDate: endDate)
    }

    private func getMinimalSugarState(target: Double, value: Double) -> SugarState {
        if abs(value - target) <= 0.5 {
            return .good
        } else if value - target >= -0.8 && value - target < 0 {
            return .normal
        } else if value - target < -0.8 {
            return .bad
        } else {
            return .good
        }
    }

    private func getAverageSugarState(target: Double, value: Double) -> SugarState {
        if abs(value - target) <= 2 {
            return .good
        } else if abs(value - target) <= 4 {
            return .normal
        } else if abs(value - target) > 4 {
            return .bad
        } else {
            return .normal
        }
    }

    private func getMaximalSugarState(target: Double, value: Double) -> SugarState {
        if value - target <= 2 {
            return .good
        } else if value - target > 2 && value - target < 3 {
            return .normal
        } else if value - target > 3 {
            return .bad
        } else {
            return .good
        }
    }

    func getSugarAnalysis() -> SugarAnalysisResult {
        return sugarAnalysisManager.analyzeSugarPatterns(history: dataSource, userDefaults: userDefaultsDataManager)
    }
}
