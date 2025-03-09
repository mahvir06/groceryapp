import Foundation

struct Store: Identifiable, Codable {
    var id: UUID
    var name: String
    var items: [GroceryItem]
    
    init(id: UUID = UUID(), name: String, items: [GroceryItem] = []) {
        self.id = id
        self.name = name
        self.items = items
    }
} 