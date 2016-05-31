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
    
    func testDemographics() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        
        //FIXME adjustToPcikerWheelValue does not work
        //ageTextField.tap()
        //app.pickerWheels.element.adjustToPickerWheelValue("Less than 18")
        
        testPicker("Age", in: app)
        testTextField("Email", in: app)
        testPicker("Gender", in: app)
        testPicker("Ethnicity", in: app)
        testPicker("Home Income", in: app)
        //FIXME unable to test ZIP fields
        //testTextField("Home ZIP", in: app)
        //testTextField("Work ZIP", in: app)
        //testTextField("School ZIP", in: app)
        app.tables.element.swipeUp()
        testPicker("Cycle Frequency", in: app)
        testPicker("Rider Type", in: app)
        testPicker("Rider History", in: app)
        
        
    }
    
    func testTextField(key:String, in app:XCUIApplication) {
        let textField = app.tables.cells.containingType(.StaticText, identifier:key).childrenMatchingType(.TextField).element
        if(textField.value as! String != "") {
            textField.pressForDuration(1.3)
            app.menuItems["Select All"].tap()
        } else {
            textField.tap()
            NSThread.sleepForTimeInterval(0.5)
        }
        app.typeText(values[key]!)
        NSThread.sleepForTimeInterval(0.5)
        XCTAssertEqual((textField.value as! String), values[key])
    }
    
    func testPicker(key:String, in app:XCUIApplication) {
        let pickerTextField = app.tables.cells.containingType(.StaticText, identifier:key).childrenMatchingType(.TextField).element
        
        //Set to blank
        pickerTextField.tap()
        app.pickerWheels.element.swipeDown()
        XCTAssertEqual((pickerTextField.value as! String), " ")
        
        //set to first option
        pickerTextField.tap()
        app.pickerWheels.element.selectNextOption()
        NSThread.sleepForTimeInterval(0.5)
        XCTAssertEqual((pickerTextField.value as! String), values[key])
        
    }
    

    
    
}
