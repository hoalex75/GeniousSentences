//
//  GeniousSentencesTests.swift
//  GeniousSentencesTests
//
//  Created by Alex on 17/10/2019.
//  Copyright © 2019 Alexandre Holet. All rights reserved.
//

import XCTest
@testable import GeniousSentences

class GeniousSentencesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testGivenSentence_WhenSplitIt_ThenWordsIntab() {
        let sentence = "Bonjour ma gueule"
        let model = Model()

        let tab = model.splitSentenceIntoWords(sentence: sentence)

        XCTAssertEqual(tab, ["Bonjour","ma","gueule"])
    }

}
