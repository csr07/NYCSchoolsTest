//
//  EventDetailsViewController.swift
//  20200303-CesarGomez-NYCSchools
//
//  Created by Cesar on 04/03/20.
//  Copyright © 2020 Cesar. All rights reserved.
//

import UIKit

class EventDetailsViewController: UITableViewController {
    
    //csrstuff
    let sat_client = SODAClient(domain: "data.cityofnewyork.us", token: "")
    let sat_dataset = "f9bf-2cp4"
    // not used anymore var sat_data: [[String: Any]]! = []
    var key_dbn = "--"
    var key_name = "--"

    var eventDictionary: [String : Any]? = nil {
        didSet {
            if let item = eventDictionary {
                let sortedArray = item.sorted{ $0.0 < $1.0 }
                print(sortedArray)
                sortedItems = sortedArray
            }
        }
    }
    var sortedItems: [(key: String, value: Any)]? = nil
        
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDBN: UILabel!
    @IBOutlet weak var lblNumTestTakers: UILabel!
    @IBOutlet weak var lblReading: UILabel!
    @IBOutlet weak var lblWriting: UILabel!
    @IBOutlet weak var lblMath: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl ()
        refreshControl?.addTarget(self, action: #selector(EventDetailsViewController.refresh(_:)), for: UIControl.Event.valueChanged)
        refresh(self)
    }
    
    /// Asynchronous performs the data query then updates the UI
    @objc
    func refresh (_ sender: Any) {
        
        let satQuery = sat_client.query(dataset: sat_dataset).filter("dbn like '\(key_dbn)'")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
        satQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    self.eventDictionary = data[0]
                    self.setSATInfo()
                }
                else {
                    self.lblName.text = self.key_name
                    self.lblDBN.text = self.key_dbn
                }
                
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alertController = UIAlertController(title: "Error Refreshing", message: errorMessage, preferredStyle:.alert)
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
            
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func setSATInfo(){
        
        for item in sortedItems! {
            
            switch item.key {
            case "school_name":
                lblName.text = item.value as! String
                break;
            case "dbn":
                lblDBN.text = item.value as! String
                break;
            case "num_of_sat_test_takers":
                lblNumTestTakers.text = item.value as! String
                break;
            case "sat_critical_reading_avg_score":
                lblReading.text = item.value as! String
                break;
            case "sat_writing_avg_score":
                lblWriting.text = item.value as! String
                break;
            case "sat_math_avg_score":
                lblMath.text = item.value as! String
                break;
            default :
                lblName.text = "No info available"
            }
        }
        
        //var t = sortedItems![0]
        //lblName.text = t.value as! String
        
    }    
}

