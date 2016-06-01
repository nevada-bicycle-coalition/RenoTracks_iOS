//
//  extensions.swift
//  RenoTracks
//
//  Created by Brian O'Neill on 5/31/16.
//
//

import XCTest

extension XCUIElement {
    /// Scrolls a picker wheel up by one option.
    func selectNextOption() {
        let startCoord = self.coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.coordinateWithOffset(CGVector(dx: 0.0, dy: 30.0))
        endCoord.tap()
    }
    
    /// Scrolls a picker wheel down by one option.
    func selectPreviousOption() {
        let startCoord = self.coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.coordinateWithOffset(CGVector(dx: 0.0, dy: -30.0))
        endCoord.tap()
    }
}