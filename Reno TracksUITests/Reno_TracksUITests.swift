//
//  Reno_TracksUITests.swift
//  Reno TracksUITests
//
//  Created by Brian O'Neill on 5/27/16.
//
//

import XCTest

class Reno_TracksUITests: XCTestCase {
    let values = ["Age":"Less than 18", "Gender":"Female", "Email":"test@mailinator.com", "Ethnicity":"White", "Home Income":"Less than $20,000", "Home ZIP":"12345", "Work ZIP":"1234", "School ZIP":"12345", "Cycle Frequency":"Less than once a month", "Rider Type":"Strong & fearless", "Rider History":"Since childhood"]
    
        
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

    //MARK: - Personal Info View
    func testDemographicsShouldUpdateWithValues() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        testPicker("Age", in: app)
        testTextField("Email", in: app)
        testPicker("Gender", in: app)
        testPicker("Ethnicity", in: app)
        testPicker("Home Income", in: app)
        testTextField("Home ZIP", in: app)
        testTextField("Work ZIP", in: app)
        testTextField("School ZIP", in: app)
        app.tables.element.swipeUp()
        testPicker("Cycle Frequency", in: app)
        testPicker("Rider Type", in: app)
        testPicker("Rider History", in: app)
    }
    
    func testDemographicsDoneButtonShouldHideKeyboard() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.cells.containingType(.StaticText, identifier:"Email").childrenMatchingType(.TextField).element.tap()
        
        //Show Keyboard
        XCTAssert(app.keyboards.count == 1)
        app.keyboards.buttons["Done"].tap()
        
        //Hide Keyboard
        XCTAssert(app.keyboards.count == 0)
        
    }
    
    //MARK: - Create Trips
    func testCreateTripWithDetails() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        sleep(5)
        app.buttons["Save"].tap()
        app.sheets.collectionViews.buttons["Save"].tap()
        app.navigationBars["Trip Purpose"].buttons["Save"].tap()
        app.typeText("Details")
        app.navigationBars["Detail"].buttons["Save"].tap()
        
        
        //Should Display Upload Complete
        let predicate = NSPredicate(format: "exists == 1")
        let query = app.staticTexts["Upload Complete"]
        expectationForPredicate(predicate, evaluatedWithObject: query, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
    }
    
    func testCreateTripWithoutDetails() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        sleep(5)
        app.buttons["Save"].tap()
        app.sheets.collectionViews.buttons["Save"].tap()
        app.navigationBars["Trip Purpose"].buttons["Save"].tap()
        app.navigationBars["Detail"].buttons["Save"].tap()
        
        
        //Should Display Upload Complete
        let predicate = NSPredicate(format: "exists == 1")
        let query = app.staticTexts["Upload Complete"]
        expectationForPredicate(predicate, evaluatedWithObject: query, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
    }
    
    
    func testDiscardTripThenLoadTripsShouldNotCrash() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        sleep(3)
        app.buttons["Save"].tap()
        app.sheets.collectionViews.buttons["Discard"].tap()
        app.tabBars.buttons["Trips"].tap()
    }
    
    //MARK: - Create Notes
    func testCreateNoteWithoutImage() {
        
        let app = XCUIApplication()
        app.buttons["Mark"].tap()
        app.pickerWheels.element.selectNextOption()
        app.navigationBars["Mark"].buttons["Save"].tap()
        app.navigationBars["Detail"].buttons["Save"].tap()
        
        //Should Display Upload Complete
        let predicate = NSPredicate(format: "exists == 1")
        let query = app.staticTexts["Upload Complete"]
        expectationForPredicate(predicate, evaluatedWithObject: query, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
    }
    
    
    //MARK: - Helper Functions
    func testTextField(key:String, in app:XCUIApplication) {
        let textField = app.tables.cells.containingType(.StaticText, identifier:key).childrenMatchingType(.TextField).element
        if(textField.value as! String != "") {
            textField.pressForDuration(1.3)
            app.menuItems["Select All"].tap()
        } else {
            textField.tap()
        }
        
        //Show Keyboard
        XCTAssert(app.keyboards.count == 1)
        
        app.typeText(values[key]!)
        NSThread.sleepForTimeInterval(0.5)
        
        //Update Value
        XCTAssertEqual((textField.value as! String), values[key])
        
        let tablesQuery = app.tables
        if (tablesQuery.otherElements["TELL US ABOUT YOURSELF"].exists) {
            tablesQuery.otherElements["TELL US ABOUT YOURSELF"].tap()
        } else if (tablesQuery.otherElements["YOUR TYPICAL COMMUTE"].exists) {
            tablesQuery.otherElements["YOUR TYPICAL COMMUTE"].tap()
        } else if (tablesQuery.otherElements["HOW OFTEN DO YOU CYCLE"].exists) {
            tablesQuery.otherElements["HOW OFTEN DO YOU CYCLE"].tap()
        } else if (tablesQuery.otherElements["WHAT KIND OF RIDER ARE YOU?"].exists) {
            tablesQuery.otherElements["WHAT KIND OF RIDER ARE YOU?"].tap()
        } else if (tablesQuery.otherElements["HOW LONG HAVE YOU BEEN A CYCLIST?"].exists) {
            tablesQuery.otherElements["HOW LONG HAVE YOU BEEN A CYCLIST?"].tap()
        } else {
            XCTAssert(false)
        }
        
        //Hide Keyboard
        XCTAssert(app.keyboards.count == 0)


    }
    
    func testPicker(key:String, in app:XCUIApplication) {
        let pickerTextField = app.tables.cells.containingType(.StaticText, identifier:key).childrenMatchingType(.TextField).element
        pickerTextField.tap()
        
        //Show Picker Wheel
        XCTAssert(app.pickerWheels.element.exists)
        app.pickerWheels.element.swipeDown()
        NSThread.sleepForTimeInterval(1.5)
        
        //Set to Blank
        XCTAssertEqual((pickerTextField.value as! String), " ")
    
        //Hide Picker Wheel
        XCTAssertFalse(app.pickerWheels.element.exists)
        
        pickerTextField.tap()
        app.pickerWheels.element.selectNextOption()
        NSThread.sleepForTimeInterval(1.5)
        
        //set to first option
        XCTAssertEqual((pickerTextField.value as! String), values[key])
        
        //Hide Picker Wheel
        XCTAssertFalse(app.pickerWheels.element.exists)
        
    }
    
}
