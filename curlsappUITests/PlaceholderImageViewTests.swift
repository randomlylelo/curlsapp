//
//  PlaceholderImageViewTests.swift
//  curlsappUITests
//
//  Created by Leo on 8/1/25.
//

import XCTest
import SwiftUI
@testable import curlsapp

final class PlaceholderImageViewTests: XCTestCase {
    
    @MainActor
    func testPlaceholderImageViewScreenshot() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Take a screenshot of the placeholder image view
        let screenshot = app.screenshot()
        
        // Create an attachment for the screenshot
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "PlaceholderImageView"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testPlaceholderImageViewExists() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Look for the SF Symbol image
        let placeholderImage = app.images["figure.strengthtraining.traditional"]
        
        // Verify the placeholder image exists
        XCTAssertTrue(placeholderImage.exists, "Placeholder image should be visible")
    }
}