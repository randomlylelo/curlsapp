import Foundation

struct ExtendedBodyPart {
    let slug: Slug
    let intensity: Int?
    let side: BodySide?
    let color: String?
    
    init(slug: Slug, intensity: Int? = nil, side: BodySide? = nil, color: String? = nil) {
        self.slug = slug
        self.intensity = intensity
        self.side = side
        self.color = color
    }
}

enum BodySide: String, CaseIterable {
    case left = "left"
    case right = "right"
}

enum ViewSide: String, CaseIterable {
    case front = "front"
    case back = "back"
}

