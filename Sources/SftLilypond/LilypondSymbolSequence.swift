import Foundation

public protocol LilypondSymbolSequence {
    
    func toSymbols(context: LilypondProcessingContext) -> [LilypondRenderable]
    
}
