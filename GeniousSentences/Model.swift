//
//  Model.swift
//  GeniousSentences
//
//  Created by Alex on 17/10/2019.
//  Copyright © 2019 Alexandre Holet. All rights reserved.
//

import Foundation

public class Model {
    private var words = [String]()

    func initWords(sentence: String) {
        words = splitSentenceIntoWords(sentence: sentence)
    }

    func splitSentenceIntoWords(sentence: String) -> [String] {
        let tab = sentence.split(separator: " ")
        var result = [String]()

        tab.forEach { word in
            let wordString = String(word)
            result.append(wordString)
        }

        return result
    }
}
