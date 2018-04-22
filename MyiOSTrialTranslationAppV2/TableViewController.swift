//
//  TableViewController.swift
//  MyiOSTrialTranslationAppV2
//
//  Created by Home on 22/04/18.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SAPFiori
import SAPCommon
import SAPFoundation

class TableViewController: FUIFormTableViewController {
    var str:String = "Nabheet"
    var translationModel = TranslationModel.init(inputData: "test Input", targetLang: 0, outputData: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FUISimplePropertyFormCell.self, forCellReuseIdentifier: FUISimplePropertyFormCell.reuseIdentifier)
        
         tableView.register(FUIListPickerFormCell.self, forCellReuseIdentifier: FUIListPickerFormCell.reuseIdentifier)
         tableView.register(FUISimplePropertyFormCell.self, forCellReuseIdentifier: FUISimplePropertyFormCell.reuseIdentifier)
        tableView.register(FUIButtonFormCell.self, forCellReuseIdentifier: FUIButtonFormCell.reuseIdentifier)
    }
    @objc func getTranslation(_ sender:UIButton!){
        
        
       var index = IndexPath(row: 0, section: 0)
    var cell = self.tableView.cellForRow(at: index)
        self.translationModel.inputData = cell?.value(forKey: "value") as! String
        

        //adding request headers
        //API Key for API Sandbox
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json;charset=UTF-8",
            "APIKey": "a4hcjXcHKxMeCZg0Af9y7GA5YUbqv6os"
        ]
        
        let parameters = [
            "sourceLanguage": "en",
            "targetLanguages": [TranslationModel.langList[self.translationModel.targetLang]],
            "units": [["value": self.translationModel.inputData]]
            ] as [String : Any]
        
        var postData: NSData? = nil
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue:0)) as NSData
        } catch {
            print(error)
        }
        
        //API endpoint for API sandbox

        let request = NSMutableURLRequest(url: NSURL(string: "https://sandbox.api.sap.com/ml/translation/translate")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        //setting request method
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData! as Data
        
        let urlSession = SAPURLSession()
        //sending request
        let dataTask = urlSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
             
                do {
                  guard  let responseObject = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)as? NSDictionary else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    
                    let root  = responseObject["units"] as? NSMutableArray
                   // let d = root!["units"] as? [String:Any]
                   // let appCid = d!["translation"] as? String
                    let abc : NSDictionary = root![0] as! NSDictionary
                   let def  = abc["translations"] as? NSMutableArray
                   let efg : NSDictionary = def![0] as! NSDictionary
                
                    self.translationModel.outputData = efg["value"] as! String
                   print(self.translationModel.outputData)
                    DispatchQueue.main.async {
                    self.tableView.reloadData()
                    }
                    //self.translationModel.outputData = responseObject.translations.value
                } catch let parseError as NSError {
                    print(parseError)
                }
            }
        })
        
        dataTask.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let row = indexPath.row
        switch row{
        case 0:
        // source text
                 let cell = tableView.dequeueReusableCell(withIdentifier:FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell
                 // Configure the cell...
                 cell.keyName = "Input Text "
                 cell.value = self.translationModel.inputData
                 cell.onChangeHandler = { self.str  = $0 }
             return cell
        case 1:
        // target language
            let cell = tableView.dequeueReusableCell(withIdentifier:FUIListPickerFormCell.reuseIdentifier, for: indexPath) as! FUIListPickerFormCell
            // Configure the cell...
            cell.keyName = "Target Language"
            cell.valueOptions = TranslationModel.langList
            cell.allowsMultipleSelection = false
            cell.allowsEmptySelection = false
            cell.isEditable = true
            if(cell.value.count == 0){
                cell.value.append(self.translationModel.targetLang)
            }else{
                cell.value[0] = self.translationModel.targetLang
            }
            cell.onChangeHandler = { self.translationModel.targetLang = $0[0] }
             return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier:FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell
            // Configure the cell...
            cell.keyName = "Translation"
            cell.value = self.translationModel.outputData
            cell.onChangeHandler = { self.str  = $0 }
          return cell
        // translated text
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier:FUIButtonFormCell.reuseIdentifier, for: indexPath) as! FUIButtonFormCell
            // Configure the cell...
            //cell.setTintColor(UIColor.red, for: .normal)
            cell.button.setTitle("Translate", for: [])
            cell.button.tintColor = UIColor.black
            cell.button.addTarget(self, action: #selector(TableViewController.getTranslation(_:)), for: .touchUpInside)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier:FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell
            return cell
        }
        

     
    }
 
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
