import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let pushNotificationManager = PushNotificationManager()
    var appGroupSugarCheckTimer: Timer?
    var lastProcessedSugar: Double?
    let coreDataManager = CoreDataManager() // Используем правильный конструктор

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Task {
            _ = try? await pushNotificationManager.registerForNotifications()
        }
        // Запускаем таймер для проверки новых данных сахара из App Group
        appGroupSugarCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkForNewSugarFromWatch()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // Проверка новых данных сахара из App Group и расчет рекомендации
    private func checkForNewSugarFromWatch() {
        let defaults = UserDefaults(suiteName: "group.com.tracksugar.appgroup")
        guard let sugarValue = defaults?.object(forKey: "lastSugar") as? Double else { return }
        
        // Проверяем, не обрабатывали ли мы уже это значение
        if lastProcessedSugar != sugarValue {
            lastProcessedSugar = sugarValue
            
            // Сохраняем в CoreData с физической активностью "Нет" (по умолчанию для watch)
            coreDataManager.addToHistory(
                breadCount: "0.0",
                sugar: String(sugarValue),
                shortInsulin: "0.0",
                longInsulin: "0.0",
                physicalActivity: "Нет"
            )
            
            // Рассчитываем рекомендацию
            let advice = calculateAdviceForSugar(sugarValue)
            
            // Записываем рекомендацию обратно в App Group
            defaults?.set(advice, forKey: "lastAdvice")
            
            print("📱 iOS: Обработан новый сахар \(sugarValue), рекомендация: \(advice)")
        }
    }
    
    private func calculateAdviceForSugar(_ sugar: Double) -> String {
        switch sugar {
        case 0..<3.9:
            return "Низкий сахар! Съешьте быстрые углеводы (сок, конфета) и перепроверьте через 15 минут."
        case 3.9..<5.5:
            return "Сахар ниже нормы. Рекомендуется легкий перекус с углеводами."
        case 5.5..<7.8:
            return "Отличный уровень сахара! Продолжайте в том же духе."
        case 7.8..<10.0:
            return "Сахар немного повышен. Обратите внимание на питание и физическую активность."
        case 10.0..<13.9:
            return "Высокий сахар. Рассмотрите возможность дополнительного инсулина или физической активности."
        default:
            return "Очень высокий сахар! Необходима консультация с врачом и возможная коррекция дозы инсулина."
        }
    }
}
