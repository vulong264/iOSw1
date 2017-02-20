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

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch displaySwitcher.selectedSegmentIndex
        {
        case 0:
            tableView.isHidden = false
            collectionView.isHidden = true
        case 1:
            tableView.isHidden = true
            collectionView.isHidden = false
        default:
            break; 
        }
        let settings = UserDefaults.standard
        settings.set(displaySwitcher.selectedSegmentIndex, forKey: "List_or_grid")
        print("saved display value \(displaySwitcher.selectedSegmentIndex)")
    }
    @IBOutlet weak var displaySwitcher: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var movies = [NSDictionary]()
    let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
    var selectedUrl = ""
    var selectedOverview = ""
    
    @IBOutlet weak var networkErrView: UIView!
    var selectedEndPoint = ""
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for custom UI display
        
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isHidden = true
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
        let url = URL(string: "http://api.themoviedb.org/3/movie/\(selectedEndPoint)?api_key=\(apiKey)")
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
//                                        print("response: \(responseDictionary)")
                                        
                                        self.tableView.reloadData()
                                        self.collectionView.reloadData()
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
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return movies.count
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath)as! MovieCollectionViewCell
        let posterUrl = posterBaseUrl + (movies[indexPath.row]["poster_path"] as! String)
        cell.collectionViewCellImage.setImageWith(NSURL(string: posterUrl)as! URL)
        return cell
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        selectedUrl = posterBaseUrl + (movies[indexPath.item]["poster_path"] as! String)
        selectedOverview = movies[indexPath.item]["overview"] as! String
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
 
    override func viewWillAppear(_ animated: Bool) {
        let settings = UserDefaults.standard
        let currentDisplay = settings.integer(forKey: "List_or_grid") ?? 0
        displaySwitcher.selectedSegmentIndex = currentDisplay
        print("loaded display value \(currentDisplay)")
        switch currentDisplay
        {
        case 0:
            tableView.isHidden = false
            collectionView.isHidden = true
        case 1:
            tableView.isHidden = true
            collectionView.isHidden = false
        default:
            break;
        }
    }
}
