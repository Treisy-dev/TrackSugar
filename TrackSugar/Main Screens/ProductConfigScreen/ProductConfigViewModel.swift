import Foundation

protocol ProductConfigViewModelProtocol {
    var userDefaultsDataManager: UserDefaultsDataManagerProtocol { get }

    func getUserBreadCount() -> String
}

final class ProductConfigViewModel: ProductConfigViewModelProtocol {

    var userDefaultsDataManager: UserDefaultsDataManagerProtocol

    init(userDefaultsDM: UserDefaultsDataManagerProtocol) {
        userDefaultsDataManager = userDefaultsDM
    }

    func getUserBreadCount() -> String {
        return userDefaultsDataManager.getUserBreadCount()
    }

}
