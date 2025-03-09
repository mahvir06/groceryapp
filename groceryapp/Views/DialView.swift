import SwiftUI

struct DialView: View {
    @Binding var items: [GroceryItem]
    @State private var rotationAngle: Double = 0
    @State private var previousDragOffset: CGSize = .zero
    
    // Constants for wheel appearance
    private let wheelRadius: CGFloat = 350 // Radius for the circular path
    private let itemSpacing: Double = (2 * Double.pi) / 18 // Reduced spacing between items
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Items on the wheel
                ForEach(0..<items.count, id: \.self) { index in
                    let angle = Double(index) * itemSpacing + rotationAngle
                    
                    // Only show items that are visible in the left portion
                    if isItemVisible(angle) {
                        itemView(for: items[index], at: angle, isActive: isActiveItem(angle))
                            .position(
                                // Center point is off-screen to the right
                                x: geometry.size.width + 100 + cos(angle) * wheelRadius,
                                y: geometry.size.height / 2 + sin(angle) * wheelRadius
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = value.translation.height - previousDragOffset.height
                        
                        // Calculate rotation based on vertical drag (inverted)
                        let rotationDelta = delta * -0.005 // Inverted the direction
                        
                        rotationAngle += rotationDelta
                        previousDragOffset = value.translation
                    }
                    .onEnded { _ in
                        previousDragOffset = .zero
                        snapToNearestItem()
                    }
            )
        }
    }
    
    // Check if an item is visible in the view
    private func isItemVisible(_ angle: Double) -> Bool {
        let normalizedAngle = normalizeAngle(angle)
        // Show items in the left portion of the wheel
        return normalizedAngle > Double.pi/4 && normalizedAngle < 7*Double.pi/4
    }
    
    // View for a single item on the wheel
    private func itemView(for item: GroceryItem, at angle: Double, isActive: Bool) -> some View {
        Text(item.name)
            .font(.system(size: isActive ? 36 : 28))
            .fontWeight(isActive ? .bold : .regular)
            .foregroundColor(.yellow)
            .opacity(opacityForItem(at: angle))
            // Fix text orientation to be right-side up and perpendicular to the circle
            .rotationEffect(.degrees(angle * (180/Double.pi) + 180))
    }
    
    // Calculate opacity based on position (items fade as they approach edges)
    private func opacityForItem(at angle: Double) -> Double {
        let normalizedAngle = normalizeAngle(angle)
        let center = Double.pi // Center of visible area
        let distance = abs(normalizedAngle - center)
        
        // Full opacity at center, fading to 0.3 at edges
        return 1.0 - min(distance / (Double.pi/2) * 0.7, 0.7)
    }
    
    // Determine if an item is the active (center) item
    private func isActiveItem(_ angle: Double) -> Bool {
        let normalizedAngle = normalizeAngle(angle)
        return abs(normalizedAngle - Double.pi) < itemSpacing / 2
    }
    
    // Normalize angle to 0 to 2π range
    private func normalizeAngle(_ angle: Double) -> Double {
        let normalized = angle.truncatingRemainder(dividingBy: 2 * Double.pi)
        return normalized >= 0 ? normalized : normalized + 2 * Double.pi
    }
    
    // Toggle the checked state of the active item
    private func toggleActiveItem() {
        // Find the active item
        for (index, _) in items.enumerated() {
            let angle = Double(index) * itemSpacing + rotationAngle
            if isActiveItem(angle) {
                items[index].isChecked.toggle()
                break
            }
        }
    }
    
    // Snap rotation to nearest item after dragging
    private func snapToNearestItem() {
        // Calculate which item should be at the center (π)
        let targetAngle = Double.pi
        let normalizedRotation = normalizeAngle(rotationAngle)
        
        // Find the nearest item index
        var nearestIndex = Int(round((targetAngle - normalizedRotation) / itemSpacing))
        nearestIndex = (nearestIndex % items.count + items.count) % items.count
        
        withAnimation(.spring()) {
            rotationAngle = targetAngle - Double(nearestIndex) * itemSpacing
        }
    }
}