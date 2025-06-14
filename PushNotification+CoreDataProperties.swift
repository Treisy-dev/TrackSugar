import Foundation
import CoreData

extension PushNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PushNotification> {
        return NSFetchRequest<PushNotification>(entityName: "PushNotification")
    }

    @NSManaged public var title: String
    @NSManaged public var message: String
    @NSManaged public var date: Date
    @NSManaged public var id: UUID

}

extension PushNotification: Identifiable {

}
