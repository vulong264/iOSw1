//
//  MoviesViewController.swift
//  W1_HW
//
//  Created by LVMBP on 2/16/17.
//  Copyright © 2017 vulong. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
    var selectedUrl = ""
    var selectedOverview = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "http://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        print("response: \(responseDictionary)")
                                        
                                        self.tableView.reloadData()
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
