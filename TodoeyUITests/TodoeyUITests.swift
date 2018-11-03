//
//  TodoeyUITests.swift
//  TodoeyUITests
//
//  Created by Robin Goh on 11/3/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import XCTest

class TodoeyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        
        let app = XCUIApplication()
        app.navigationBars["Todoey"].buttons["Add"].tap()
        app.alerts["Add new todo"].collectionViews.textFields["Enter new todo"].tap()
        app.typeText("get an awesome job")
        app.alerts["Add new todo"].buttons["Add"].tap()
        app.otherElements.containing(.navigationBar, identifier:"Todoey").children(matching: .other).element.children(matching: .other).element.children(matching: .table).element.swipeUp()
    }
    
}
