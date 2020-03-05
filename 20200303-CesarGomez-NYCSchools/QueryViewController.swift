//
//  QueryViewController.swift
//  20200303-CesarGomez-NYCSchools
//
//  Created by Cesar on 04/03/20.
//  Copyright © 2020 Cesar. All rights reserved.
//

import UIKit

class QueryViewController: UITableViewController {
    
    let client = SODAClient(domain: "data.cityofnewyork.us", token: "")
    let cellId = "EventSummaryCell"
    var data: [[String: Any]]! = []
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl ()
        refreshControl?.addTarget(self, action: #selector(QueryViewController.refresh(_:)), for: UIControl.Event.valueChanged)
        
        refresh(self)
    }
    
    /// Asynchronous performs the data query then updates the UI
    @objc
    func refresh (_ sender: Any) {

        let cngQuery = client.query(dataset: "s3k6-pzi2")//.filter("boro like 'M'")
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cngQuery.orderAscending("school_name").get { res in
            switch res {
            case .dataset (let data):
                self.data = data
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alertController = UIAlertController(title: "Error Refreshing", message: errorMessage, preferredStyle:.alert)
                self.present(alertController, animated: true, completion: nil)
            }
            
            // Update the UI
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) else {
            fatalError("Error: Cell identifier is misconfigured")
        }
        
        let item = data[indexPath.row]
        
        let name = item["school_name"]! as! String
        cell.textLabel?.text = name
        
        var neighborhood = "--";
        if let neighborhood_temp = item["neighborhood"] as! String? {
            neighborhood = neighborhood_temp
        }
        
        var borough = "--";
        if let borough_temp = item["borough"] as! String? {
            borough = borough_temp
        }
        
        //let neighborhood = item["neighborhood"]! as! String
        //let borough = item["borough"]! as! String
        let state = "NY"
        cell.detailTextLabel?.text = "\(neighborhood), \(borough), \(state)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetails" {
        
            let item = data[self.tableView.indexPathForSelectedRow!.row]
            
            let detailsVC = segue.destination as! EventDetailsViewController
                        
            detailsVC.key_dbn = item["dbn"]! as! String
            detailsVC.key_name = item["school_name"]! as! String
            
        }
    }
}
