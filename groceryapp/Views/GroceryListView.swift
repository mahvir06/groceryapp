import SwiftUI

struct GroceryListView: View {
    @State private var items: [GroceryItem] = []
    @State private var showingAddItem = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Dial view
                DialView(items: $items)
                    .frame(height: UIScreen.main.bounds.height * 0.9)
                    .id(items.count)
                
                Spacer()
                
                // Add button at bottom
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView { itemName in
                    withAnimation(nil) {
                        let newItem = GroceryItem(name: itemName)
                        items.append(newItem)
                        saveItems()
                    }
                }
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    func addItem(_ name: String) {
        withAnimation(nil) {
            let item = GroceryItem(name: name)
            items.append(item)
            saveItems()
        }
    }
    
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "groceryItems"),
           let decoded = try? JSONDecoder().decode([GroceryItem].self, from: data) {
            items = decoded
        } else {
            // Add sample items if none exist
            items = [
                GroceryItem(name: "Banana"),
                GroceryItem(name: "Spinach"),
                GroceryItem(name: "Milk"),
                GroceryItem(name: "Carrots"),
                GroceryItem(name: "Oats"),
                GroceryItem(name: "Chicken"),
                GroceryItem(name: "Apples"),
                GroceryItem(name: "Bread"),
                GroceryItem(name: "Eggs"),
                GroceryItem(name: "Tomatoes")
            ]
        }
    }
    
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "groceryItems")
        }
    }
}

#Preview {
    GroceryListView()
} 