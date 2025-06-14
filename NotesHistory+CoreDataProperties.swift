import Foundation
import CoreData

extension NotesHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesHistory> {
        return NSFetchRequest<NotesHistory>(entityName: "NotesHistory")
    }

    @NSManaged public var sugar: Double
    @NSManaged public var breadCount: Double
    @NSManaged public var shortInsulin: Double
    @NSManaged public var date: Date
    @NSManaged public var id: UUID?
    @NSManaged public var longInsulin: Double
    @NSManaged public var physicalActivity: String?

}

extension NotesHistory: Identifiable {

}
