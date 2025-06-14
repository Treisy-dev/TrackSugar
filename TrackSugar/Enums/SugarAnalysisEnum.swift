import Foundation

enum SugarPattern {
    case postMealSpike          // Скачок после еды
    case fastingRise            // Подъем натощак
    case hypoglycemia           // Гипогликемия
    case stable                 // Стабильный уровень
    case delayedInsulinEffect   // Задержанный эффект инсулина
    case insufficientInsulin    // Недостаточный инсулин
    case excessiveInsulin       // Избыточный инсулин
}

enum AdviceType {
    case preMealInsulin         // Инсулин перед едой
    case checkLongInsulin       // Проверить продленный инсулин
    case adjustMealTiming       // Скорректировать время еды
    case increaseInsulin        // Увеличить дозу инсулина
    case decreaseInsulin        // Уменьшить дозу инсулина
    case checkBasalRate         // Проверить базальную скорость
    case fastingTest            // Тест голодания
    case consultDoctor          // Консультация с врачом
}

struct SugarAdvice {
    let type: AdviceType
    let title: String
    let description: String
    let confidence: Double // 0.0 - 1.0
    let urgency: Urgency
}

enum Urgency {
    case low
    case medium
    case high
    case critical
}

struct SugarAnalysisResult {
    let pattern: SugarPattern
    let advice: [SugarAdvice]
    let trend: String
    let riskLevel: RiskLevel
}

enum RiskLevel {
    case low
    case medium
    case high
    case critical
} 
