import Foundation

enum Slug: String, CaseIterable {
    case abs, adductors, ankles, biceps, calves, chest, deltoids
    case feet, forearm, gluteal, hamstring, hands, hair, head
    case knees, lowerBack = "lower-back", neck, obliques
    case quadriceps, tibialis, trapezius, triceps, upperBack = "upper-back"
}

struct BodyPartPath {
    let common: [String]?
    let left: [String]?
    let right: [String]?
    
    init(common: [String]? = nil, left: [String]? = nil, right: [String]? = nil) {
        self.common = common
        self.left = left
        self.right = right
    }
}

struct BodyPart {
    let slug: Slug
    let color: String
    let path: BodyPartPath
}