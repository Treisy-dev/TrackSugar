import Foundation
import CoreData

extension TemplateProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateProduct> {
        return NSFetchRequest<TemplateProduct>(entityName: "TemplateProduct")
    }

    @NSManaged public var name: String
    @NSManaged public var carbohydrates: String
    @NSManaged public var protein: String
    @NSManaged public var fat: String
    @NSManaged public var id: UUID
    @NSManaged public var template: Templates?

}

extension TemplateProduct: Identifiable {

}
