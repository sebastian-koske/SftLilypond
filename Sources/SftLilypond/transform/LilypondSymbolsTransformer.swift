import Foundation
import SftMusicModel

/**
 Transforms musical sequences into corresponding lLilypond Symbols
 */
// version 0.2.0
public class LilypondSymbolsTransformer {
    
    private let context: LilypondProcessingContext
    
    // version 0.2.0
    public init(context: LilypondProcessingContext) {
        self.context = context
    }
    
    // version 0.2.0
    public func transform(sequence: NamedStaffBarSequence) -> [LilypondPrimarySymbol] {
        
      
        return [.relative(.c, sequence.primaryElements)]
        
    }
    
    // version 0.2.0
    public func transform(staffBarSequence: StaffBarSequenceUnion) -> [LilypondPrimarySymbol] {
        
        switch staffBarSequence {
//        case let .relative(tone, primaries, _):
//            return [.relative(tone, primaries)]
        case let .inner(primaries, _):
            return primaries.flatMap(self.transform)
        case let .staffBar(bar):
            return transformStaffBar(staffBar: bar)
        case let .volta(volta):
            return [.volta(volta)]
        }
    }
    
    public func transform(staffPrimaryElement: StaffPrimaryElementUnion) -> [LilypondPrimarySymbol] {
        switch staffPrimaryElement {
            
        case let .playable(playable):
            switch playable {
                
            case let .toneOrRest(t):
                switch t {
                case let .tone(tone):
                    return [.tone(tone)]
                case let .rest(duration):
                    return [.rest(duration)]
                }
            case let .tole(tole):
                return [.tole(tole)]
            }
        case let .bar(barline):
            return [.barLine(barline)]
        case let .key(key):
            return [.key(key)]
        case let .time(time):
            return [.time(time)]
        case let .tempo(tempo):
            return [.tempo(tempo)]
        case let .lineBreak(mode):
            return [.lineBreak(mode)]
        case let .mark(mark):
            return [.mark(mark)]
        case let .volta(volta):
            return [.volta(volta)]
        }
        
    }
    
    private func transformStaffBar(staffBar: StaffBar) -> [LilypondPrimarySymbol] {
        
        var result = staffBar.primaryElements.flatMap(self.transform)
        
        if let tempo = staffBar.tempo {
            result.insert(.tempo(tempo), at: 0)
        }
        
        if let key = staffBar.key {
            result.insert(.key(key), at: 0)
        }
        
        if let time = staffBar.time {
            result.insert(.time(time), at: 0)
        }
        
        if let mark = staffBar.mark {
            result.insert(.mark(mark), at: 0)
        }
        
        result.insert(.lineBreak(staffBar.breakMode), at: 0)
        
        if let startLine = staffBar.startLine {
            result.insert(.barLine(startLine), at: 0)
        }
        
        if let endLine = staffBar.endLine {
            result.append(.barLine(endLine))
        }
        
        return result
    }

}
