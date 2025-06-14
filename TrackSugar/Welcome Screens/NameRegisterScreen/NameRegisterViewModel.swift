import Foundation

protocol NameRegisterViewModelProtocol {
    func saveUserInfo(name: String?, email: String?)
}

final class NameRegisterViewModel: NameRegisterViewModelProtocol {

    let userDefaultsDataManager: UserDefaultsDataManagerProtocol

    init(userDefaultsDM: UserDefaultsDataManagerProtocol) {
        userDefaultsDataManager = userDefaultsDM
    }

    func saveUserInfo(name: String?, email: String?) {
        userDefaultsDataManager.addNameToUserInfo(name: name, email: email)
    }
}
