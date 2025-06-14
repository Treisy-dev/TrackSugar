import Foundation

protocol SugarAnalysisManagerProtocol {
    func analyzeSugarPatterns(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> SugarAnalysisResult
    func getAdviceForPattern(_ pattern: SugarPattern, userDefaults: UserDefaultsDataManagerProtocol) -> [SugarAdvice]
    func detectPostMealSpikes(history: [NotesHistory]) -> Bool
    func detectFastingRise(history: [NotesHistory]) -> Bool
    func detectHypoglycemia(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> Bool
    func calculateTrend(history: [NotesHistory]) -> String
    func calculateRiskLevel(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> RiskLevel
}

final class SugarAnalysisManager: SugarAnalysisManagerProtocol {
    
    // Пороговые значения для анализа
    private let postMealSpikeThreshold: Double = 3.0 // ммоль/л выше целевого через 2 часа
    private let fastingRiseThreshold: Double = 2.0 // ммоль/л выше целевого натощак
    private let hypoglycemiaThreshold: Double = 3.9 // ммоль/л
    private let excessiveInsulinThreshold: Double = 2.0 // ммоль/л ниже целевого
    
    func analyzeSugarPatterns(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> SugarAnalysisResult {
        guard !history.isEmpty else {
            print("SugarAnalysis: Недостаточно данных для анализа")
            return SugarAnalysisResult(
                pattern: .stable,
                advice: [],
                trend: "Недостаточно данных для анализа",
                riskLevel: .low
            )
        }
        
        let sortedHistory = history.sorted { $0.date < $1.date }
        print("SugarAnalysis: Анализируем \(sortedHistory.count) записей")
        
        let pattern = detectPattern(sortedHistory, userDefaults: userDefaults)
        print("SugarAnalysis: Обнаружен паттерн: \(pattern)")
        
        let advice = getAdviceForPattern(pattern, userDefaults: userDefaults)
        print("SugarAnalysis: Сгенерировано \(advice.count) советов")
        
        let trend = calculateTrend(history: sortedHistory)
        let riskLevel = calculateRiskLevel(history: sortedHistory, userDefaults: userDefaults)
        
        return SugarAnalysisResult(
            pattern: pattern,
            advice: advice,
            trend: trend,
            riskLevel: riskLevel
        )
    }
    
    private func detectPattern(_ history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> SugarPattern {
        if detectPostMealSpikes(history: history) {
            return .postMealSpike
        }
        
        if detectFastingRise(history: history) {
            return .fastingRise
        }
        
        if detectHypoglycemia(history: history, userDefaults: userDefaults) {
            return .hypoglycemia
        }
        
        // Анализ паттернов инсулина
        if detectExcessiveInsulin(history: history, userDefaults: userDefaults) {
            return .excessiveInsulin
        }
        
        if detectInsufficientInsulin(history: history, userDefaults: userDefaults) {
            return .insufficientInsulin
        }
        
        if detectDelayedInsulinEffect(history: history) {
            return .delayedInsulinEffect
        }
        
        return .stable
    }
    
    func detectPostMealSpikes(history: [NotesHistory]) -> Bool {
        guard history.count >= 2 else { return false }
        
        var spikeCount = 0
        let totalMeals = history.count - 1
        
        for i in 0..<history.count-1 {
            let current = history[i]
            let next = history[i + 1]
            
            let timeDifference = next.date.timeIntervalSince(current.date) / 3600 // в часах
            
            // Проверяем измерения через 1-3 часа после еды
            if timeDifference >= 1.0 && timeDifference <= 3.0 {
                let sugarIncrease = next.sugar - current.sugar
                if sugarIncrease > postMealSpikeThreshold {
                    spikeCount += 1
                    print("SugarAnalysis: Обнаружен скачок сахара: \(current.sugar) -> \(next.sugar) (+\(sugarIncrease)) через \(timeDifference) часов")
                }
            }
        }
        
        let spikeRate = Double(spikeCount) / Double(totalMeals)
        print("SugarAnalysis: Скачки после еды: \(spikeCount)/\(totalMeals) (\(spikeRate * 100)%)")
        
        // Если более 50% приемов пищи вызывают скачки
        return spikeRate > 0.5
    }
    
    func detectFastingRise(history: [NotesHistory]) -> Bool {
        guard history.count >= 2 else { return false }
        
        var riseCount = 0
        var totalFastingPeriods = 0
        
        for i in 0..<history.count-1 {
            let current = history[i]
            let next = history[i + 1]
            
            let timeDifference = next.date.timeIntervalSince(current.date) / 3600 // в часах
            
            // Проверяем ночные периоды (6+ часов без еды)
            if timeDifference >= 6.0 {
                totalFastingPeriods += 1
                let sugarIncrease = next.sugar - current.sugar
                if sugarIncrease > fastingRiseThreshold {
                    riseCount += 1
                }
            }
        }
        
        return totalFastingPeriods > 0 && Double(riseCount) / Double(totalFastingPeriods) > 0.3
    }
    
    func detectHypoglycemia(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> Bool {
        let lowTarget = Double(userDefaults.getLowTarget()) ?? 4.0
        
        let hypoglycemiaCount = history.filter { $0.sugar < lowTarget }.count
        let hypoglycemiaRate = Double(hypoglycemiaCount) / Double(history.count)
        
        print("SugarAnalysis: Гипогликемии: \(hypoglycemiaCount)/\(history.count) (\(hypoglycemiaRate * 100)%)")
        print("SugarAnalysis: Целевой нижний уровень: \(lowTarget)")
        
        return hypoglycemiaRate > 0.2 // Более 20% измерений
    }
    
    private func detectExcessiveInsulin(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> Bool {
        let lowTarget = Double(userDefaults.getLowTarget()) ?? 4.0
        
        var excessiveCount = 0
        for record in history {
            if record.sugar < lowTarget && record.shortInsulin > 0 {
                excessiveCount += 1
                print("SugarAnalysis: Избыточный инсулин: сахар \(record.sugar) при дозе \(record.shortInsulin)")
            }
        }
        
        let excessiveRate = Double(excessiveCount) / Double(history.count)
        print("SugarAnalysis: Избыточный инсулин: \(excessiveCount)/\(history.count) (\(excessiveRate * 100)%)")
        
        return excessiveRate > 0.15
    }
    
    private func detectInsufficientInsulin(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> Bool {
        let highTarget = Double(userDefaults.getHighTarget()) ?? 10.0
        
        var insufficientCount = 0
        for record in history {
            if record.sugar > highTarget && record.shortInsulin > 0 {
                insufficientCount += 1
                print("SugarAnalysis: Недостаточный инсулин: сахар \(record.sugar) при дозе \(record.shortInsulin)")
            }
        }
        
        let insufficientRate = Double(insufficientCount) / Double(history.count)
        print("SugarAnalysis: Недостаточный инсулин: \(insufficientCount)/\(history.count) (\(insufficientRate * 100)%)")
        
        return insufficientRate > 0.3
    }
    
    private func detectDelayedInsulinEffect(history: [NotesHistory]) -> Bool {
        guard history.count >= 3 else { return false }
        
        var delayedCount = 0
        for i in 0..<history.count-2 {
            let first = history[i]
            let second = history[i + 1]
            let third = history[i + 2]
            
            let timeToSecond = second.date.timeIntervalSince(first.date) / 3600
            let timeToThird = third.date.timeIntervalSince(first.date) / 3600
            
            // Если сахар сначала растет, а потом падает через 2+ часа
            if timeToSecond >= 1.0 && timeToSecond <= 2.0 && timeToThird >= 2.0 {
                if second.sugar > first.sugar && third.sugar < second.sugar {
                    delayedCount += 1
                }
            }
        }
        
        return delayedCount > 0
    }
    
    func getAdviceForPattern(_ pattern: SugarPattern, userDefaults: UserDefaultsDataManagerProtocol) -> [SugarAdvice] {
        switch pattern {
        case .postMealSpike:
            return [
                SugarAdvice(
                    type: .preMealInsulin,
                    title: "Вводите инсулин заранее",
                    description: "Ваш сахар поднимается после еды. Попробуйте вводить короткий инсулин за 15-20 минут до приема пищи.",
                    confidence: 0.8,
                    urgency: .medium
                ),
                SugarAdvice(
                    type: .adjustMealTiming,
                    title: "Скорректируйте время еды",
                    description: "Увеличьте интервал между введением инсулина и приемом пищи.",
                    confidence: 0.7,
                    urgency: .medium
                )
            ]
            
        case .fastingRise:
            return [
                SugarAdvice(
                    type: .checkLongInsulin,
                    title: "Проверьте продленный инсулин",
                    description: "Сахар поднимается натощак. Возможно, нужно скорректировать дозу продленного инсулина.",
                    confidence: 0.9,
                    urgency: .high
                ),
                SugarAdvice(
                    type: .fastingTest,
                    title: "Проведите тест голодания",
                    description: "Попробуйте пропустить один прием пищи и понаблюдать за сахаром для оценки базального инсулина.",
                    confidence: 0.8,
                    urgency: .medium
                )
            ]
            
        case .hypoglycemia:
            return [
                SugarAdvice(
                    type: .decreaseInsulin,
                    title: "Уменьшите дозу инсулина",
                    description: "У вас частые гипогликемии. Рассмотрите возможность уменьшения дозы инсулина.",
                    confidence: 0.9,
                    urgency: .high
                ),
                SugarAdvice(
                    type: .consultDoctor,
                    title: "Консультация с врачом",
                    description: "Частые гипогликемии требуют медицинской консультации для коррекции терапии.",
                    confidence: 0.95,
                    urgency: .critical
                )
            ]
            
        case .delayedInsulinEffect:
            return [
                SugarAdvice(
                    type: .preMealInsulin,
                    title: "Увеличьте время до еды",
                    description: "Эффект инсулина проявляется с задержкой. Увеличьте интервал между инъекцией и едой до 20-30 минут.",
                    confidence: 0.8,
                    urgency: .medium
                )
            ]
            
        case .insufficientInsulin:
            return [
                SugarAdvice(
                    type: .increaseInsulin,
                    title: "Увеличьте дозу инсулина",
                    description: "Сахар остается высоким после введения инсулина. Возможно, нужно увеличить дозу.",
                    confidence: 0.8,
                    urgency: .high
                ),
                SugarAdvice(
                    type: .checkBasalRate,
                    title: "Проверьте базальную скорость",
                    description: "Рассмотрите возможность увеличения базальной скорости инсулина.",
                    confidence: 0.7,
                    urgency: .medium
                )
            ]
            
        case .excessiveInsulin:
            return [
                SugarAdvice(
                    type: .decreaseInsulin,
                    title: "Уменьшите дозу инсулина",
                    description: "Слишком много инсулина вызывает гипогликемии. Уменьшите дозу.",
                    confidence: 0.9,
                    urgency: .high
                )
            ]
            
        case .stable:
            return [
                SugarAdvice(
                    type: .consultDoctor,
                    title: "Отличный контроль!",
                    description: "Ваш сахар стабилен. Продолжайте в том же духе!",
                    confidence: 0.9,
                    urgency: .low
                )
            ]
        }
    }
    
    func calculateTrend(history: [NotesHistory]) -> String {
        guard history.count >= 3 else { return "Недостаточно данных" }
        
        let sortedHistory = history.sorted { $0.date < $1.date }
        let recentHistory = Array(sortedHistory.suffix(7)) // Последние 7 измерений
        
        var increasingCount = 0
        var decreasingCount = 0
        
        for i in 0..<recentHistory.count-1 {
            if recentHistory[i+1].sugar > recentHistory[i].sugar {
                increasingCount += 1
            } else if recentHistory[i+1].sugar < recentHistory[i].sugar {
                decreasingCount += 1
            }
        }
        
        if increasingCount > decreasingCount * 2 {
            return "Сахар имеет тенденцию к повышению"
        } else if decreasingCount > increasingCount * 2 {
            return "Сахар имеет тенденцию к снижению"
        } else {
            return "Сахар относительно стабилен"
        }
    }
    
    func calculateRiskLevel(history: [NotesHistory], userDefaults: UserDefaultsDataManagerProtocol) -> RiskLevel {
        let lowTarget = Double(userDefaults.getLowTarget()) ?? 4.0
        let highTarget = Double(userDefaults.getHighTarget()) ?? 10.0
        
        let hypoglycemiaCount = history.filter { $0.sugar < lowTarget }.count
        let hyperglycemiaCount = history.filter { $0.sugar > highTarget }.count
        let totalCount = history.count
        
        let hypoglycemiaRate = Double(hypoglycemiaCount) / Double(totalCount)
        let hyperglycemiaRate = Double(hyperglycemiaCount) / Double(totalCount)
        
        if hypoglycemiaRate > 0.3 || hyperglycemiaRate > 0.5 {
            return .critical
        } else if hypoglycemiaRate > 0.2 || hyperglycemiaRate > 0.3 {
            return .high
        } else if hypoglycemiaRate > 0.1 || hyperglycemiaRate > 0.2 {
            return .medium
        } else {
            return .low
        }
    }
} 
