//
//  Classifier.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 02/01/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class Classifier {

    private let majorProfile = ToneProfile(profile: Constants.majorProfile)
    private let minorProfile = ToneProfile(profile: Constants.minorProfile)
    private let silenceProfile = ToneProfile(profile: [Float](repeating: 0, count: Constants.bands))

    func classify(chromaVector: [Float]) -> Constants.Key {
        var scores = [Float](repeating: 0, count: Constants.semitones * 2)
        for i in 0..<Constants.semitones {
            scores[i*2] = majorProfile.cosineSimilarity(input: chromaVector, offset: i)
            scores[(i*2)+1] = minorProfile.cosineSimilarity(input: chromaVector, offset: i)
        }
        var bestScore: Float = silenceProfile.cosineSimilarity(input: chromaVector, offset: 0)
        var bestMatch = Constants.Key.silence
        for (i, score) in scores.enumerated() where score > bestScore {
            bestScore = score
            bestMatch = Constants.Key.allCases[i]
        }
        return bestMatch
    }
}
