import Foundation

public protocol LilypondRenderable {
    
    func toLilypondString(context: LilypondProcessingContext) -> String
    
}
