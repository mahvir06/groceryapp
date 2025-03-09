import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var itemName = ""
    let onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    TextField("Item name", text: $itemName)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.yellow)
                        .accentColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                        .padding()
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.yellow),
                trailing: Button("Add") {
                    if !itemName.isEmpty {
                        onAdd(itemName)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.yellow)
            )
        }
        .colorScheme(.dark)
        .onDisappear {
            // Force a redraw of the parent view when this view disappears
            DispatchQueue.main.async {
                // This empty block forces a UI update
            }
        }
    }
} 