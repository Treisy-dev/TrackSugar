import Foundation
import CoreData

extension UserProducts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProducts> {
        return NSFetchRequest<UserProducts>(entityName: "UserProducts")
    }

    @NSManaged public var name: String
    @NSManaged public var protein: String
    @NSManaged public var fat: String
    @NSManaged public var carbohydrates: String
    @NSManaged public var category: String

}

extension UserProducts: Identifiable {

}
