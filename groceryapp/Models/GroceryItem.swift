import Foundation

struct GroceryItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var isChecked: Bool
    var orderIndex: Int?
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false, orderIndex: Int? = nil) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.orderIndex = orderIndex
    }
} 