import Foundation

import SftMusicModel

public class LilypondProcessingContext {
    
    public var currentKey = Key(.c, .major)
    public var currentTime = TimeSignature(1, 4)
    
    public init() {
    }
    
}
