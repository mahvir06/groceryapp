import SwiftUI

struct DialView: View {
    @Binding var items: [GroceryItem]
    @State private var rotationAngle: Double = 0
    @State private var previousDragOffset: CGSize = .zero
    @State private var isAtBoundary: Bool = false
    @State private var previousItemCount: Int = 0
    @State private var lastRotationAngle: Double = 0
    
    // Constants for wheel appearance
    private let wheelRadius: CGFloat = 350 // Radius for the circular path
    private let itemSpacing: Double = (2 * Double.pi) / 18 // Reduced spacing between items
    private let bounceAmount: Double = 0.2 // Amount of bounce when hitting boundaries
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Items on the wheel - reversed to show newest items at the bottom
                ForEach(0..<items.count, id: \.self) { index in
                    // Reverse the index to display newest items at the bottom
                    let reversedIndex = items.count - 1 - index
                    let angle = Double(index) * itemSpacing + rotationAngle
                    
                    // Only show items that are visible in the left portion
                    if isItemVisible(angle) {
                        itemView(for: items[reversedIndex], at: angle, isActive: isActiveItem(angle))
                            .position(
                                // Center point is off-screen to the right
                                x: geometry.size.width + 100 + cos(angle) * wheelRadius,
                                y: geometry.size.height / 2 + sin(angle) * wheelRadius
                            )
                            .onTapGesture {
                                if isActiveItem(angle) {
                                    // When center item is tapped, scroll to next item
                                    scrollToNextItem()
                                }
                            }
                    }
                }
                
                // Delete button for the active item
                if !items.isEmpty {
                    VStack {
                        Spacer()
                        Button(action: {
                            deleteActiveItem()
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                        }
                        .padding(.bottom, 100)
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
                        
                        // Check if we're at boundaries
                        let newRotation = rotationAngle + rotationDelta
                        
                        // Check if we're at the top or bottom boundary
                        if isAtTopBoundary(newRotation) || isAtBottomBoundary(newRotation) {
                            // Apply reduced movement with bounce effect
                            rotationAngle += rotationDelta * 0.3
                            isAtBoundary = true
                        } else {
                            rotationAngle += rotationDelta
                            isAtBoundary = false
                        }
                        
                        previousDragOffset = value.translation
                    }
                    .onEnded { _ in
                        previousDragOffset = .zero
                        
                        // If we were at a boundary, apply bounce-back animation
                        if isAtBoundary {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                // Ensure we're within valid bounds
                                if isAtTopBoundary(rotationAngle) {
                                    rotationAngle = getTopBoundaryAngle()
                                } else if isAtBottomBoundary(rotationAngle) {
                                    rotationAngle = getBottomBoundaryAngle()
                                }
                            }
                            isAtBoundary = false
                        } else {
                            snapToNearestItem()
                        }
                        
                        // Store the last rotation angle
                        lastRotationAngle = rotationAngle
                    }
            )
            .onAppear {
                // Initialize previousItemCount
                previousItemCount = items.count
                
                // Set initial rotation to center the list
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    rotationAngle = Double.pi
                    lastRotationAngle = rotationAngle
                }
            }
            .onChange(of: items.count) { newCount, _ in
                // If items were added, adjust rotation to maintain position
                if newCount > previousItemCount {
                    // Restore the previous rotation angle to prevent scrolling
                    rotationAngle = lastRotationAngle
                } else if newCount < previousItemCount {
                    // Item was deleted, adjust rotation if needed
                    snapToNearestItem()
                }
                previousItemCount = newCount
            }
        }
    }
    
    // Delete the active item
    private func deleteActiveItem() {
        // Find the active item
        for (index, _) in items.enumerated() {
            let angle = Double(index) * itemSpacing + rotationAngle
            if isActiveItem(angle) {
                // Use the reversed index to match the display order
                let reversedIndex = items.count - 1 - index
                
                // Remove the item
                withAnimation {
                    items.remove(at: reversedIndex)
                }
                break
            }
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
            .font(.system(size: getFontSize(for: angle)))
            .fontWeight(getFontWeight(for: angle))
            .foregroundColor(.yellow)
            .opacity(opacityForItem(at: angle))
            // Fix text orientation to be right-side up and perpendicular to the circle
            .rotationEffect(.degrees(angle * (180/Double.pi) + 180))
            .contentShape(Rectangle()) // Improve tap area
            .animation(.easeOut(duration: 0.2), value: isActive) // Smooth animation for font changes
    }
    
    // Calculate font size based on proximity to center (smooth transition)
    private func getFontSize(for angle: Double) -> CGFloat {
        let normalizedAngle = normalizeAngle(angle)
        let center = Double.pi // Center of visible area
        let distance = abs(normalizedAngle - center)
        let maxDistance = itemSpacing * 2
        
        // Smoothly transition from 36 at center to 28 at edges
        let minSize: CGFloat = 28
        let maxSize: CGFloat = 36
        let sizeDifference = maxSize - minSize
        
        let normalizedDistance = min(distance / maxDistance, 1.0)
        return maxSize - (CGFloat(normalizedDistance) * sizeDifference)
    }
    
    // Calculate font weight based on proximity to center (smooth transition)
    private func getFontWeight(for angle: Double) -> Font.Weight {
        let normalizedAngle = normalizeAngle(angle)
        let center = Double.pi
        let distance = abs(normalizedAngle - center)
        
        // Use interpolation for smoother transition
        if distance < itemSpacing * 0.3 {
            return .bold
        } else if distance < itemSpacing * 0.6 {
            return .semibold
        } else if distance < itemSpacing {
            return .medium
        } else {
            return .regular
        }
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
                // Use the reversed index to match the display order
                let reversedIndex = items.count - 1 - index
                items[reversedIndex].isChecked.toggle()
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
    
    // Check if we're at the top boundary (first item)
    private func isAtTopBoundary(_ angle: Double) -> Bool {
        let normalizedRotation = normalizeAngle(angle)
        let firstItemAngle = Double.pi - (Double(0) * itemSpacing)
        return normalizedRotation > firstItemAngle - itemSpacing / 2
    }
    
    // Check if we're at the bottom boundary (last item)
    private func isAtBottomBoundary(_ angle: Double) -> Bool {
        let normalizedRotation = normalizeAngle(angle)
        let lastItemAngle = Double.pi - (Double(items.count - 1) * itemSpacing)
        return normalizedRotation < lastItemAngle + itemSpacing / 2
    }
    
    // Get the angle for the top boundary
    private func getTopBoundaryAngle() -> Double {
        return Double.pi
    }
    
    // Get the angle for the bottom boundary
    private func getBottomBoundaryAngle() -> Double {
        return Double.pi - (Double(items.count - 1) * itemSpacing)
    }
    
    // Scroll to the next item (item above the current center)
    private func scrollToNextItem() {
        // Find the current active item index
        var activeIndex = -1
        for (index, _) in items.enumerated() {
            let angle = Double(index) * itemSpacing + rotationAngle
            if isActiveItem(angle) {
                activeIndex = index
                break
            }
        }
        
        // If we found an active item and it's not the first one
        if activeIndex != -1 && activeIndex > 0 {
            // Calculate the angle for the previous item (the one above)
            let previousIndex = activeIndex - 1
            let targetAngle = Double.pi - (Double(previousIndex) * itemSpacing)
            
            // Animate to the previous item
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                rotationAngle = targetAngle
            }
        }
    }
}