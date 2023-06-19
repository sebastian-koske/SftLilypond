import Foundation

import SftMusicModel

/**
 Represents mutable state in processing
 */
// version 0.2.0
public class LilypondProcessingContext {
    
    public var currentKey = Key(.c, .major)
    public var currentTime = TimeSignature(1, 4)
    
    public init() {
    }
    
}
