import Foundation

import SftMusicModel

public enum LilypondPrimary {
    
    case barLine(BarLine)
    case key(Key)
    case lineBreak(BreakMode)
    case mark(String)
    case relative(ChromaticNoteSymbol, [StaffPrimaryElementUnion])
    case rest(MusicalDuration)
    case tempo(Tempo)
    case time(TimeSignature)
    case tole(NTole)
    case tone(PlayedTone)
    case volta(Volta)
    
}

extension PlayedToneOrRest {
    public func renderablePrimaries2(context: LilypondProcessingContext) -> [LilypondPrimary] {
        switch self {
            
        case let .tone(t):
            return [.tone(t)]
        case let .rest(r):
            return [.rest(r)]
        }
    }
    
}
