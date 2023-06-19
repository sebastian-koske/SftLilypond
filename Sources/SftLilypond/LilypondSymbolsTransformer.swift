import Foundation
import SftMusicModel

public class LilypondSymbolsTransformer {
    
    private let context: LilypondProcessingContext
    
    public init(context: LilypondProcessingContext) {
        self.context = context
    }
    
    public func transform(staffBarSequence: StaffBarSequenceUnion) -> [LilypondPrimary] {
        
        switch staffBarSequence {
        case let .named(primaries, _):
            return [.relative(.c, primaries)]
        case let .regular(primaries, _):
            return primaries.flatMap(self.transform)
        case let .staffBar(bar):
            return transform(bar: bar)
        case let .volta(volta):
            return [.volta(volta)]
        }
    }
    
    public func transform(staffPrimaryElement: StaffPrimaryElementUnion) -> [LilypondPrimary] {
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
    
    private func transform( bar: StaffBar) -> [LilypondPrimary] {
        
        var result = bar.primaryElements.flatMap(self.transform)
        
        if let tempo = bar.tempo {
            result.insert(.tempo(tempo), at: 0)
        }
        
        if let key = bar.key {
            result.insert(.key(key), at: 0)
        }
        
        if let time = bar.time {
            result.insert(.time(time), at: 0)
        }
        
        if let mark = bar.mark {
            result.insert(.mark(mark), at: 0)
        }
        
        result.insert(.lineBreak(bar.breakMode), at: 0)
        
        if let startLine = bar.startLine {
            result.insert(.barLine(startLine), at: 0)
        }
        
        if let endLine = bar.endLine {
            result.append(.barLine(endLine))
        }
        
        return result
    }

}
