import Foundation

import SftMusicModel

public enum LilypondPrimaries {
    
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
    
    public func toLilypondString(context: LilypondProcessingContext) -> String {
        switch self {
        case let .barLine(barLine):
            return render(barLine)
        case let .key(key):
            return render(key, context)
        case let .lineBreak(breakMode):
            return render(breakMode)
        case let .mark(mark):
            return renderMark(mark)
        case let .relative(note, sequence):
            return  "\\relative \(render(note)) { \(render(sequence.flatMap{ $0.renderablePrimaries(context: context) }, context: context)) }"
        case let .rest(rest):
            return renderRest(rest, context)
        case let .tempo(tempo):
            return render(tempo)
        case let .time(time):
            return render(time, context)
        case let .tole(tole):
            return render(tole, context)
        case let .tone(tone):
            return render(tone, context)
        case let .volta(volta):
            return renderVolta(volta.primaryContent, volta.alternatives, context: context)
        }
    }
    
    private func renderVolta(_ primary: StaffBarSequence, _ alternatives: [StaffBarSequence], context: LilypondProcessingContext) -> String {
        
        let total = alternatives.count
        
        let primary = "\\repeat volta \(total) { \(render(primary, context: context)) }"
        
        let alternatives = alternatives
            .map{ render($0, context: context) }
            .map{ "{ \($0) }"}
            .joined(separator: " ")
        
        var result = primary
        result += "\\alternative { \(alternatives) }"
        
        return result
        
    }
    
    private func render(_ sequence: StaffBarSequence, context: LilypondProcessingContext) -> String {
        return render(sequence.union.renderablePrimaries(context: context), context: context)
    }
    
    private func render(_ primaries: [LilypondPrimaries], context: LilypondProcessingContext) -> String {
        return primaries
            .map{ $0.toLilypondString(context: context) }
            .joined(separator: " ")
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
    
    private func render(_ time: TimeSignature, _ context: LilypondProcessingContext) -> String {
        let currentTime = context.currentTime
        if currentTime == time {
            return ""
        }
        
        context.currentTime = time
        return "\\time \(time.length)/\(time.fraction) \\set Score.voltaSpannerDuration = #(ly:make-moment \(time.length)/\(time.fraction)) "
    }
    
    private func render(_ key: Key, _ context: LilypondProcessingContext) -> String {
        let currentKey = context.currentKey
        if currentKey == key {
            return ""
        }
        
        
        context.currentKey = key
        return "\\key \(render(key.tonic)) \(render(key.type)) "
    }
    
    private func render(_ keyType: KeyType) -> String {
        switch(keyType) {
            
        case .major:
            return "\\major"
        case .minor:
            return "\\minor"
        }
        
    }
    
    private func renderRest(_ duration: MusicalDuration, _ context: LilypondProcessingContext) -> String {
        switch(duration) {
        case .noteDuration(_):
            return "r" + render(duration, context)
        case .fullMeasure:
            return "R" + render(duration, context)
        }
    }
    
    private func render(_ playedTone: PlayedTone, _ context: LilypondProcessingContext) -> String {
        return render(playedTone.tone, context)
        + render(playedTone.accent)
        + (playedTone.hasPostTie ? "~"  : "")
        + (playedTone.hasPreTie ? "\\repeatTie"  : "")
    }
    
    private func render(_ duration: MusicalDuration, _ context: LilypondProcessingContext) -> String {
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
    
    private func render(_ tone: AbsoluteChromaticTone, _ context: LilypondProcessingContext) -> String {
        return render(tone.note) + render(tone.duration, context)
    }
    
    private func render(_ note: AbsoluteChromaticNote) -> String {
        return render(note.note) + octaveShift(note.octave)
    }
    
    private func render(_ note: ChromaticNoteSymbol) -> String {
        return String(describing: note.diatonicNote) + render(note.chromaticPitch)
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
    
    private func render(_ accent: Accent?) -> String {
        
        guard let accent = accent else {
            return ""
        }
        
        switch(accent) {
            
        case .dot: return "-."
        case .dash: return "--"
        }
    }
    
    private func render(_ tempo: Tempo) -> String {
        let result = "\\tempo 4 = \(tempo.min)"
        
        guard let to = tempo.max else {
            return result
        }
        
        return result + " - \(to)"
    }
    
    public func render(_ tole: NTole, _ context: LilypondProcessingContext) -> String {
        let innerContent = tole.toneOrRests
            .flatMap{ $0.renderablePrimaries(context: context) }
            .map{ $0.toLilypondString(context: context) }
            .joined(separator: " ")
        
        return "\\tuplet \(tole.play)/\(tole.over) { \(innerContent) }"
    }
}
