//
//  SettingsTableViewController.swift
//  RenoTracks
//
//  Created by Brian O'Neill on 7/8/16.
//
//

import UIKit



public class SettingsTableViewController: UITableViewController {
    
    struct demographicInput {
        let label:String, dbTitle:String, type:SettingsTextTableViewCell.keyboardType, values:Array<String>?
        init(label:String, dbTitle:String, type:SettingsTextTableViewCell.keyboardType, values:Array<String>? = nil)
        {
            self.label = label
            self.dbTitle = dbTitle
            self.type = type
            self.values = values
        }
    }
    
    let genderArray = [" ", "Female","Male"]
    
    let ageArray = [" ", "Less than 18", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    
    let ethnicityArray = [" ", "White", "African American", "Asian", "Native American", "Pacific Islander", "Multi-racial", "Hispanic / Mexican / Latino", "Other"]
    
    let incomeArray = [" ", "Less than $20,000", "$20,000 to $39,999", "$40,000 to $59,999", "$60,000 to $74,999", "$75,000 to $99,999", "$100,000 or greater"]
    
    let cyclingFreqArray = [" ", "Less than once a month", "Several times per month", "Several times per week", "Daily"]
    
    let rider_typeArray = [" ", "Strong & fearless", "Enthused & confident", "Comfortable, but cautious", "Interested, but concerned"]
    
    let rider_historyArray = [" ", "Since childhood", "Several years", "One year or less", "Just trying it out / just started"]
    
    
    let textFieldArray = ["age","email","gender","ethnicity","income","homeZIP","workZIP","schoolZIP","cyclingFreq","rider_type","rider_history"]
    
    var demographicsArray:Array<demographicInput>? = nil
    
    
    
    
        
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //Create Demographic Data Structure (This could be moved to app thinning)
        
        
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Data Methods
    func loadDemographicOptions() {
        //demographicsArray?.
        demographicsArray?.append(demographicInput(label: "Age", dbTitle: "age", type: .Picker, values: ageArray))
        demographicsArray?.append(demographicInput(label: "Email", dbTitle: "email", type: .Email))
        demographicsArray?.append(demographicInput(label: "Gender", dbTitle: "gender", type: .Picker, values: genderArray))
        demographicsArray?.append(demographicInput(label: "Ethnicity", dbTitle: "ethnicity", type: .Picker, values: ethnicityArray))
        demographicsArray?.append(demographicInput(label: "Home Income", dbTitle: "income", type: .Picker, values: incomeArray))
        demographicsArray?.append(demographicInput(label: "Home ZIP", dbTitle: "email", type: .Email))
        demographicsArray?.append(demographicInput(label: "Email", dbTitle: "email", type: .Email))
        demographicsArray?.append(demographicInput(label: "Email", dbTitle: "email", type: .Email))
        
        
        ["age","email","gender","ethnicity","income","homeZIP","workZIP","schoolZIP","cyclingFreq","rider_type","rider_history"]
    }
    

    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsText", forIndexPath: indexPath) as! SettingsTextTableViewCell
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = "test1"
            cell.setType(.Numeric)
        case 1:
            cell.valueLabel.text = "test2"
            cell.setType(.Email)
        default:
            break
        }
        
        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
