import UIKit

enum TemplateCategories: String {
    case breakfast = "Завтрак"
    case snack = "Перекус"
    case secondBreakfast = "Второй завтрак"
    case lunch = "Обед"
    case dinner = "Ужин"
    case afternoonSnack = "Второй ужин"
    case none = ""

    func getImageByType() -> UIImage {
        switch self {
        case .breakfast:
            return UIImage.breakfast.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .snack:
            return UIImage.snack.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .secondBreakfast:
            return UIImage.secondBreakfast.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .lunch:
            return UIImage.lunch.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .dinner:
            return UIImage.diner.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .afternoonSnack:
            return UIImage.afternoonSnack.resizeImage(newSize: CGSize(width: 45, height: 45))
        case .none:
            return UIImage.lunch.resizeImage(newSize: CGSize(width: 45, height: 45))
        }
    }
}
