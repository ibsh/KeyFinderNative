//
//  ToneProfile.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 01/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class Binode<T> {
    var l: Binode<T>?
    var r: Binode<T>?
    var value: T

    init(value: T) {
        self.value = value
    }
}

final class ToneProfile {

    private let tonics: [Binode<Float>]

    init(profile: [Float]) {

        guard profile.count == Constants.Analysis.bands else {
            fatalError("Tone profile must have 72 elements")
        }

        var tonics = [Binode<Float>]()

        for o in 0..<Constants.Analysis.octaves {
            var tonic = Binode<Float>(value: profile[o * Constants.Analysis.semitones])
            var q = tonic
            for s in 1..<Constants.Analysis.semitones {
                let new = Binode<Float>(value: profile[o * Constants.Analysis.semitones + s])
                q.r = new
                new.l = q
                q = new
            }
            q.r = tonic
            tonic.l = q

            // offset from A to C (3 semitones)
            for _ in 0..<3 {
                tonic = tonic.r!
            }

            tonics.append(tonic)
        }

        self.tonics = tonics
    }

    deinit {
        for o in 0..<Constants.Analysis.octaves {
            var p = tonics[o]
            repeat {
                let zap = p
                p = p.r!
                zap.l = nil
                zap.r = nil
            } while p.r != nil
        }
    }

    func cosineSimilarity(input: [Float], offset: Int) -> Float {

        guard input.count == Constants.Analysis.bands else {
            fatalError("Chroma data must have 72 elements")
        }

        let semitones = Constants.Analysis.semitones

        var intersection: Float = 0.0
        var profileNorm: Float = 0.0
        var inputNorm: Float = 0.0

        for o in 0..<Constants.Analysis.octaves {
            // Rotate starting pointer left for offset. Each step shifts the position
            // of the tonic one step further right of the starting pointer (or one semitone up).
            var p = tonics[o]
            for _ in 0..<offset {
                p = p.l!
            }

            for i in (o * semitones)..<((o + 1) * semitones) {
                intersection += input[i] * p.value
                profileNorm += pow((p.value), 2)
                inputNorm += pow((input[i]), 2)
                p = p.r!
            }
        }

        // div by zero check
        if profileNorm > 0 && inputNorm > 0 {
            return intersection / (sqrt(profileNorm) * sqrt(inputNorm))
        } else {
            return 0
        }
    }
}
