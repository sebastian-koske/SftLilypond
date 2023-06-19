import Foundation
import SftMusicModel

public class LilypondRenderer {
    
    private let context: LilypondProcessingContext
    private let symbolTransformer: LilypondSymbolsTransformer
    
    public init(context: LilypondProcessingContext) {
        self.context = context
        self.symbolTransformer = LilypondSymbolsTransformer(context: context)
    }
    
    public func toLilypondString(sequence: NamedStaffBarSequence) -> String {
        let symbols: [LilypondPrimarySymbol] = symbolTransformer.transform(sequence: sequence)
        return render(symbols)
    }
    
    private func render(_ primaries: [LilypondPrimarySymbol]) -> String {
        return primaries
            .map(self.toLilypondString)
            .joined(separator: " ")
    }
    
    private func toLilypondString(_ p: LilypondPrimarySymbol) -> String {
        switch p {
        case let .barLine(barLine):
            return render(barLine)
        case let .key(key):
            return render(key)
        case let .lineBreak(breakMode):
            return render(breakMode)
        case let .mark(mark):
            return renderMark(mark)
        case let .relative(note, sequence):
            return  "\\relative \(render(note)) { \(render( sequence.flatMap{ symbolTransformer.transform(staffPrimaryElement: $0) })) }"
        case let .rest(rest):
            return renderRest(rest)
        case let .tempo(tempo):
            return render(tempo)
        case let .time(time):
            return render(time)
        case let .tole(tole):
            return render(tole: tole)
        case let .tone(tone):
            return render(tone)
        case let .volta(volta):
            return renderVolta(primarySequence: volta.primaryContent, alternativeSequences: volta.alternatives)
        }
    }
    
    private func render(_ barLine: BarLine) -> String {
        let b = { switch barLine {
        case .repeatStart:
            return ".|:-||"
        case .repeatEnd:
            return ":|."
        case .doubleBar:
            return "||"
        case .normal:
            return "|"
        }}()
        return " \\bar \"\(b)\" "
    }
    
    private func render(_ key: Key) -> String {
        let currentKey = context.currentKey
        if currentKey == key {
            return ""
        }
        
        context.currentKey = key
        return "\\key \(render(key.tonic)) \(render(key.type)) "
    }
    
    private func render(_ mode: BreakMode) -> String {
        
        switch mode {
        case .regular:
            return ""
        case .noBreak:
            return " \\noBreak "
        case .newLine:
            return " \\break "
        }
    }
    
    private func renderMark(_ mark: String) -> String {
        return "\\mark \\markup { \\rounded-box \\pad-markup #0.2 \\bold \\large  \"\(mark)\" } "
    }
    
    private func render(_ note: ChromaticNoteSymbol) -> String {
        return String(describing: note.diatonicNote) + render(note.chromaticPitch)
    }
    
    private func render(_ pitch: ChromaticPitchSymbol) -> String {
        switch(pitch) {
        case .natural:
            return ""
        case .flat:
            return "es"
        case .sharp:
            return "is"
        }
    }
    
    private func render(_ keyType: KeyType) -> String {
        switch(keyType) {
            
        case .major:
            return "\\major"
        case .minor:
            return "\\minor"
        }
        
    }
    
    private func renderRest(_ duration: MusicalDuration) -> String {
        switch(duration) {
        case .noteDuration(_):
            return "r" + render(duration)
        case .fullMeasure:
            return "R" + render(duration)
        }
    }
    
    private func render(_ duration: MusicalDuration) -> String {
        switch(duration) {
        case let .noteDuration(duration):
            return render(duration.measureFraction) + String(repeating: ".", count: duration.dots)
        case let .fullMeasure(count):
            return "1*\(context.currentTime.length)/\(context.currentTime.fraction)" + (count > 1 ? "*\(count)" : "")
        }
    }
    
    private func render(_ measureFraction: MeasureFraction) -> String {
        return "\((4 * quarterFraction(measureFraction)) / steps(measureFraction))"
    }
    
    private func quarterFraction(_ m: MeasureFraction) -> Int {
        switch(m) {
        case .whole:
            return 1
        case .half:
            return 1
        case .quarter:
            return 1
        case .eigth:
            return 2
        case .sixteenth:
            return 4
        }
    }
    
    private func steps(_ m: MeasureFraction) -> Int {
        switch(m) {
        case .whole:
            return 4
        case .half:
            return 2
        case .quarter:
            return 1
        case .eigth:
            return 1
        case .sixteenth:
            return 1
        }
    }
    
    private func render(_ tempo: Tempo) -> String {
        let result = "\\tempo 4 = \(tempo.min)"
        
        guard let to = tempo.max else {
            return result
        }
        
        return result + " - \(to)"
    }
    
    private func render(_ time: TimeSignature) -> String {
        let currentTime = context.currentTime
        if currentTime == time {
            return ""
        }
        
        context.currentTime = time
        return "\\time \(time.length)/\(time.fraction) \\set Score.voltaSpannerDuration = #(ly:make-moment \(time.length)/\(time.fraction)) "
    }
    
    private func render(tole: NTole) -> String {
        let innerContent = render(tole.toneOrRests.flatMap(symbolTransformer.transform))
        return "\\tuplet \(tole.play)/\(tole.over) { \(innerContent) }"
    }
    
    private func render(_ playedTone: PlayedTone) -> String {
        return render(playedTone.tone)
        + render(playedTone.accent)
        + (playedTone.hasPostTie ? "~"  : "")
        + (playedTone.hasPreTie ? "\\repeatTie"  : "")
    }
    
    private func render(_ accent: Accent?) -> String {
        
        guard let accent = accent else {
            return ""
        }
        
        switch(accent) {
            
        case .dot: return "-."
        case .dash: return "--"
        }
    }
    
    private func render(_ tone: AbsoluteChromaticTone) -> String {
        return render(tone.note) + render(tone.duration)
    }
    
    private func render(_ note: AbsoluteChromaticNote) -> String {
        return render(note.note) + octaveShift(note.octave)
    }
    
    private func octaveShift(_ _octave: Int) -> String {
        if (_octave > 0) {
            return String(repeating: "'", count: _octave)
        }
        
        if (_octave < 0) {
            return String(repeating: ",", count:abs(_octave))
        }
        
        return ""
    }
    
    private func renderVolta(primarySequence: StaffBarSequence, alternativeSequences: [StaffBarSequence]) -> String {
        
        let total = alternativeSequences.count
        
        let primary = "\\repeat volta \(total) { \(render(symbolTransformer.transform(staffBarSequence: primarySequence.union))) }"
        
        let alternatives = alternativeSequences
            .map{ $0.union }
            .map(symbolTransformer.transform)
            .map(self.render)
            .map{ "{ \($0) }"}
            .joined(separator: " ")
        
        var result = primary
        result += "\\alternative { \(alternatives) }"
        
        return result
        
    }
}
