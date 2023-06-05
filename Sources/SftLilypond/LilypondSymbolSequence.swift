import Foundation

public protocol LilypondSymbolSequence {
    
    func renderablePrimaries(context: LilypondProcessingContext) -> [LilypondPrimaries]
    
}
