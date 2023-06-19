import Foundation

import SftMusicModel

/**
 Represents all Lilypond primary symbols
 */
// version 0.2.0
public enum LilypondPrimarySymbol {
    
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
