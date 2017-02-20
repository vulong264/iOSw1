//
//  MoviesViewController.swift
//  W1_HW
//
//  Created by LVMBP on 2/16/17.
//  Copyright © 2017 vulong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
    var selectedUrl = ""
    var selectedOverview = ""
    let NOW_PLAYING = "now_playing"
    let TOP_RATED = "top_rated"
    
    @IBOutlet weak var networkErrView: UIView!
    var selectedEndPoint = ""
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        if Reachability.isConnectedToNetwork() == true
        {
            networkErrView.isHidden = true
            print("Connected to network")
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        else
        {
            networkErrView.isHidden = false
            print("NOT Connected to network")
        }
        // Initialize a UIRefreshControl
        selectedEndPoint = NOW_PLAYING
        
        // set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        
        loadData()
    }
    func refresh(sender:AnyObject) {
        self.loadData()
    }
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func loadData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "http://api.themoviedb.org/3/movie/"+selectedEndPoint+"?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        print("response: \(responseDictionary)")
                                        
                                        self.tableView.reloadData()
                                        // Tell the refreshControl to stop spinning
                                        // tell refresh control it can stop showing up now
                                        if self.refreshControl.isRefreshing
                                        {
                                            self.refreshControl.endRefreshing()
                                        }
                                    }
                                }
            })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return movies.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        cell.movieTitle.text = movies[indexPath.row]["title"] as? String
        cell.movieOverview.text = movies[indexPath.row]["overview"] as? String
        let posterUrl = posterBaseUrl + (movies[indexPath.row]["poster_path"] as! String)
        cell.posterImage.setImageWith(NSURL(string: posterUrl)as! URL)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUrl = posterBaseUrl + (movies[indexPath.row]["poster_path"] as! String)
        selectedOverview = movies[indexPath.row]["overview"] as! String
        performSegue(withIdentifier: "viewDetailsSegue", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destination as! DetailsViewController
        nextVC.imgUrl = selectedUrl
        nextVC.overview = selectedOverview
    }
 

}
