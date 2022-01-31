//
//  Classifier.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class Classifier {

    private let majorProfile = ToneProfile(profile: Constants.Analysis.majorProfile)
    private let minorProfile = ToneProfile(profile: Constants.Analysis.minorProfile)
    private let silenceProfile = ToneProfile(profile: [Float](repeating: 0, count: Constants.Analysis.bands))

    func classify(chromaVector: [Float]) -> Key {
        var scores = [Float](repeating: 0, count: Constants.Analysis.semitones * 2)
        for i in 0..<Constants.Analysis.semitones {
            scores[i*2] = majorProfile.cosineSimilarity(input: chromaVector, offset: i)
            scores[(i*2)+1] = minorProfile.cosineSimilarity(input: chromaVector, offset: i)
        }
        var bestScore: Float = silenceProfile.cosineSimilarity(input: chromaVector, offset: 0)
        var bestMatch = Key.silence
        for (i, score) in scores.enumerated() where score > bestScore {
            bestScore = score
            bestMatch = Key.allCases[i]
        }
        return bestMatch
    }
}
