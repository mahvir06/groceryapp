import Foundation

struct GroceryItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var isChecked: Bool
    var orderIndex: Int?
    var lastClickedDate: Date?
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false, orderIndex: Int? = nil, lastClickedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.orderIndex = orderIndex
        self.lastClickedDate = lastClickedDate
    }
} 