import Foundation
import UIKit

protocol NewNoteViewModelProtocol: UITableViewDataSource {
    var averageSugar: String { get }
    var userProducts: [UserProductModel] { get }

    func saveNewNote(breadCount: String, sugar: String, shortInsulin: String, longInsulin: String, physicalActivity: String)
    func getBreadCount() -> String
    func getInsulinCount() -> String
    func getAverageSugar() -> String
    func addUserProduct(product: UserProductModel)
}

final class NewNoteViewModel: NSObject, NewNoteViewModelProtocol, UITableViewDataSource {
    var averageSugar: String
    var coreDataManager: CoreDataManagerProtocol
    var userDefaultsDataManager: UserDefaultsDataManagerProtocol
    var userProducts: [UserProductModel] = []

    init(coreDM: CoreDataManagerProtocol, userDefaultsDM: UserDefaultsDataManagerProtocol) {
        coreDataManager = coreDM
        userDefaultsDataManager = userDefaultsDM
        averageSugar = coreDataManager.obtainAverageSugar()
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationReceived),
            name: Notification.Name("resetNoteChangesNotification"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("resetNoteChangesNotification"), object: nil)
    }

    @objc func notificationReceived(_ notification: Notification) {
        userProducts = []
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userProducts.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userProducts.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !userProducts[indexPath.row].isTemplate {
            let productCategory = coreDataManager.obtainCategoryFromProduct(for: userProducts[indexPath.row].name)
            let cell = UserProductTableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            let category = getCategoryFromStringProduct(productCategory ?? "")
            cell.config(
                productName: userProducts[indexPath.row].name,
                productCategory: category,
                proteinCount: userProducts[indexPath.row].protein,
                productStats: (userProducts[indexPath.row].fat, userProducts[indexPath.row].carbs, userProducts[indexPath.row].breadCount)
            )
            return cell
        } else {
            let productCategory = coreDataManager.obtainCategoryFromTemplate(for: userProducts[indexPath.row].name)
            let cell = UserProductTableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            let category = getCategoryFromStringTemplate(productCategory ?? "")
            cell.configTemplate(
                productName: userProducts[indexPath.row].name,
                templateCategory: category,
                proteinCount: userProducts[indexPath.row].protein,
                productStats: (userProducts[indexPath.row].fat, userProducts[indexPath.row].carbs, userProducts[indexPath.row].breadCount)
            )
            return cell
        }

    }

    func getAverageSugar() -> String {
        averageSugar = coreDataManager.obtainAverageSugar()
        return averageSugar
    }

    func saveNewNote(breadCount: String, sugar: String, shortInsulin: String, longInsulin: String, physicalActivity: String) {
        coreDataManager.addToHistory(breadCount: breadCount, sugar: sugar, shortInsulin: shortInsulin, longInsulin: longInsulin, physicalActivity: physicalActivity)
    }

    func getBreadCount() -> String {
        var result: Double = 0
        for product in userProducts {
            guard let breadCount = Double(product.breadCount) else { return ""}
            result += breadCount
        }
        return String(format: "%.1f", result)
    }

    func getInsulinCount() -> String {
        guard let breadCount = Double(getBreadCount()) else { return ""}
        guard let insulinCount = Double(userDefaultsDataManager.getUserInsulinCount()) else { return ""}

        return String(format: "%.1f", breadCount * insulinCount)
    }

    func addUserProduct(product: UserProductModel) {
        userProducts.append(product)
    }

    private func getCategoryFromStringProduct(_ categoryString: String) -> ProductCategories {
        if let category = ProductCategories(rawValue: categoryString) {
            return category
        } else {
            return .none
        }
    }

    private func getCategoryFromStringTemplate(_ categoryString: String) -> TemplateCategories {
        if let category = TemplateCategories(rawValue: categoryString) {
            return category
        } else {
            return .none
        }
    }
}
