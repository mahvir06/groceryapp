import SwiftUI

struct GroceryListView: View {
    @State private var items: [GroceryItem] = []
    @State private var showingAddItem = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header with navigation
                HStack {
                    Button(action: {
                        // Back action
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.yellow)
                        .font(.title3)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // More options
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                    
                    Spacer().frame(width: 20)
                    
                    Button(action: {
                        // Done action
                    }) {
                        Text("Done")
                            .foregroundColor(.yellow)
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Dial view
                DialView(items: $items)
                    .frame(height: UIScreen.main.bounds.height * 0.8)
                
                Spacer()
                
                // Add button at bottom
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.yellow)
                        .padding(15)
                        .background(Circle().stroke(Color.yellow, lineWidth: 2))
                }
                .padding(.bottom, 30)
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView { itemName in
                    addItem(itemName)
                }
            }
            .onAppear(perform: loadItems)
        }
    }
    
    func addItem(_ name: String) {
        let item = GroceryItem(name: name)
        items.append(item)
        saveItems()
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