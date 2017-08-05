//
//  ViewController.swift
//  FootballSchedule
//
//  Created by Preston Grisham on 7/29/16.
//  Copyright © 2016 Preston Grisham. All rights reserved.
//

import Cocoa

class Team: NSObject {
    
    var teamName: String!
    var teamMarket: String!
    var teamID: String!
}

class Game: NSObject {
    
    var homeTeam: Team!
    var awayTeam: Team!
    var startTime: String?
    var gameCity: String?
    var gameState: String?
}

class ViewController: NSViewController {

    var sessionConfig: URLSessionConfiguration?
    var session: URLSession?
    var SECTeams = [Team]()
    var teamsDictionary = NSMutableDictionary()
    var displayString = String()
    var allTeams = [Team]()
    
    @IBOutlet weak var arkansasButton: NSButton!
    @IBOutlet weak var alabamaButton: NSButton!
    @IBOutlet weak var auburnButton: NSButton!
    @IBOutlet weak var texasAMButton: NSButton!
    @IBOutlet weak var mississippiStateButton: NSButton!
    @IBOutlet weak var oleMissButton: NSButton!
    @IBOutlet weak var lsuButton: NSButton!
    @IBOutlet weak var ForkButton: NSButton!
    @IBOutlet weak var georgiaButton: NSButton!
    @IBOutlet weak var vanderbiltButton: NSButton!
    @IBOutlet weak var southCarolinaButton: NSButton!
    @IBOutlet weak var floridaButton: NSButton!
    @IBOutlet weak var missouriButtons: NSButton!
    @IBOutlet weak var tennesseeButton: NSButton!
    @IBOutlet weak var kentuckyButton: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var searchTimeLabel: NSTextField!
    @IBOutlet weak var outputScrollView: NSScrollView!
    @IBOutlet var outputTextView: NSTextView!
    
    let queue = OperationQueue()
    @IBOutlet weak var getInternetDataButton: NSButton!
    var allSchoolButtons: [NSButton]!
    @IBOutlet weak var maxThreads: NSTextField!
    @IBOutlet weak var buttonMatrix: NSMatrix!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionConfig = URLSessionConfiguration.default
        session = URLSession.shared
        allSchoolButtons = [arkansasButton, alabamaButton, auburnButton, texasAMButton, mississippiStateButton,oleMissButton, lsuButton,georgiaButton, vanderbiltButton,southCarolinaButton,floridaButton,missouriButtons,tennesseeButton, kentuckyButton]

        //TeamScheduleFromFile("SC")
        populateAllTeamsArray()
        //queue.maxConcurrentOperationCount = 4
    }
    
    @IBAction func clearConsolePressed(_ sender: AnyObject) {
        outputTextView.string = " "
        
    }
    
    @IBAction func selectAllPressed(_ sender: NSButton) {
        for button in allSchoolButtons {
            button.state = NSOnState
        }
    }
    
    @IBAction func clearAllPressed(_ sender: NSButton) {
        for button in allSchoolButtons {
            button.state = NSOffState
        }
    }
    
    @IBAction func allTeamsPressed(_ sender: NSButton) {
        //outputTextView.textStorage?.mutableString.setString("This is going to take awhile: Will not display results here!!")

        let startTime = Date()
        self.spinner.startAnimation(nil)
        
        if ForkButton.state == NSOnState {
            for team in allTeams {
                queue.addOperation({ 
                    self.TeamScheduleFromFile(team.teamID)
                })
            }
            queue.waitUntilAllOperationsAreFinished()
            let endTime = Date()
            let runningTime = endTime.timeIntervalSince(startTime)
            searchTimeLabel.isHidden = false
            self.spinner.stopAnimation(nil)
            searchTimeLabel.stringValue = ("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
            //outputTextView.string = displayString
        } else {
            for team in allTeams {
                TeamScheduleFromFile(team.teamID)
            }
            let endTime = Date()
            let runningTime = endTime.timeIntervalSince(startTime)
            searchTimeLabel.isHidden = false
            self.spinner.stopAnimation(nil)
            searchTimeLabel.stringValue = ("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
            //outputTextView.string = displayString
        }
        

        
        
    }
    
    @IBAction func getSchedulesPushed(_ sender: NSButton) {
        
        let startTime = Date()
        self.spinner.startAnimation(nil)
        
        let currentCellTitle = buttonMatrix.selectedCell()?.title
        if currentCellTitle == "Max" {
            queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        } else if currentCellTitle == "2" {
            queue.maxConcurrentOperationCount = 2
        } else {
            queue.maxConcurrentOperationCount = 4
        }

        outputTextView.textStorage?.mutableString.setString(" ")
        displayString = " "
        
        if (arkansasButton.state == NSOnState) {
            generateScheduleOutput("ARK")
        }
        if (alabamaButton.state == NSOnState) {
            generateScheduleOutput("BAMA")
        }
        if (auburnButton.state == NSOnState) {
            generateScheduleOutput("AUB")
        }
        if (texasAMButton.state == NSOnState) {
            generateScheduleOutput("TXAM")
        }
        if (mississippiStateButton.state == NSOnState) {
           generateScheduleOutput("MSST")
        }
        if (oleMissButton.state == NSOnState) {
           generateScheduleOutput("MIS")
        }
        if (lsuButton.state == NSOnState) {
           generateScheduleOutput("LSU")
        }
        if (georgiaButton.state == NSOnState) {
            generateScheduleOutput("UGA")
        }
        if (vanderbiltButton.state == NSOnState) {
            generateScheduleOutput("VAN")
        }
        if (southCarolinaButton.state == NSOnState) {
            generateScheduleOutput("SC")
        }
        if (floridaButton.state == NSOnState) {
            generateScheduleOutput("FLA")
        }
        if (missouriButtons.state == NSOnState) {
            generateScheduleOutput("MIZ")
        }
        if (tennesseeButton.state == NSOnState) {
            generateScheduleOutput("TEN")
        }
        if (kentuckyButton.state == NSOnState) {
            generateScheduleOutput("KEN")
        }
        
        
        queue.waitUntilAllOperationsAreFinished()
        let endTime = Date()
        let runningTime = endTime.timeIntervalSince(startTime)
        print("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
        searchTimeLabel.isHidden = false
        searchTimeLabel.stringValue = ("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
        self.spinner.stopAnimation(nil)
        outputTextView.string = displayString
        
        
    }
    
    func generateScheduleOutput(_ teamID: String) {
        
        if ForkButton.state == NSOnState {
            if getInternetDataButton.state == NSOnState {
                queue.addOperation({
                    self.getTeamSchedule(teamID)
                })
            } else {
                queue.addOperation({
                    self.TeamScheduleFromFile(teamID)
                })
            }
            
        } else {
            if getInternetDataButton.state == NSOnState {
                self.getTeamSchedule(teamID)
            } else {
               self.TeamScheduleFromFile(teamID)
            }
            
        }
        
    }
    
    func populateTeamData(_ division: String) {
        
    let urlString = "https://api.sportradar.us/ncaafb-t1/teams/\(division)/hierarchy.json?api_key=6aeuunrjq3yrsjz9v6u8jfft"
    let url = URL(string: urlString)
    sessionConfig = URLSessionConfiguration.default
    session = URLSession(configuration: sessionConfig!)
    let task = self.session!.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
        
        var jsonResult = NSDictionary()
        do {
            print("Running Serialization")
            jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            //---get the path of the Documents folder---
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
            let documentsDirectory = paths.first! as NSString
            
            //---full path of file to save in---
            let filePath = documentsDirectory.appendingPathComponent("AllTeams\(division).json")
            
            //print("Writing allTeamsJSON: \(jsonResult.writeToFile(filePath, atomically: true))")

            
        } catch _ {
            print("Error downloading team information")
        }
        let divisionId = jsonResult["id"] as? String
        //let divisionName = jsonResult["name"] as? String
        
        let conferencesArray = jsonResult["conferences"] as! [AnyObject]
        for conference in conferencesArray {
            let conferenceId = conference["id"] as? String
                print(conferenceId)
                let conferenceName = conference["name"] as? String
                if let _ = conference["subdivisions"] as? [AnyObject] {
                    let subdivisions = conference["subdivisions"] as! [AnyObject]
                    for subdivision in subdivisions {
                        let subdivisionId = subdivision["id"] as? String
                        let subdivisionName = subdivision["name"] as? String
                        let subdivisionTeams = subdivision["teams"] as! [AnyObject]
                        for team in subdivisionTeams {
                            
                            let secTeam = Team()
                            secTeam.teamName = team["name"] as? String
                            secTeam.teamMarket = team["market"] as? String
                            secTeam.teamID = team["id"] as? String
                            self.teamsDictionary.setValue(secTeam, forKey: (team["id"] as? String)!)
                            print("Teams Dictionary Count: \(self.teamsDictionary.count)")

                            }
                        //---get the path of the Documents folder---
                        let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
                        let documentsDirectory2 = paths2.first! as NSString
                        
                        //---full path of file to save in---
                        let filePath2 = documentsDirectory2.appendingPathComponent("allTeams.plist")
                        print(self.teamsDictionary.write(toFile: filePath2, atomically: true))
                        print("team write to file called")
                        
                        }
                    } else {
                        
                        let teams = conference["teams"] as! [AnyObject]
                        for team in teams {
                            print(team["name"] as? String)
                            
                        }
                    }
            
        }
        
    })
    task.resume()
}
    
    func findTeamFromID(_ teamID: String) -> Team {
        
        var foundTeam = false
        let startTime = Date()
        let path = Bundle.main.path(forResource: "AllTeams", ofType: "json")
        let jsonResult = NSDictionary(contentsOfFile: path!)
        
        let conferencesArray = jsonResult!["conferences"] as! [AnyObject]
        for conference in conferencesArray {
            let conferenceId = conference["id"] as? String
                let conferenceName = conference["name"] as? String
                if let _ = conference["subdivisions"] as? [AnyObject] {
                    let subdivisions = conference["subdivisions"] as! [AnyObject]
                    for subdivision in subdivisions {
                        let subdivisionId = subdivision["id"] as? String
                        let subdivisionName = subdivision["name"] as? String
                        let subdivisionTeams = subdivision["teams"] as! [AnyObject]
                        for team in subdivisionTeams {
                            
                            if (team["id"] as? String == teamID) {
                                let secTeam = Team()
                                secTeam.teamName = team["name"] as? String
                                secTeam.teamMarket = team["market"] as? String
                                secTeam.teamID = team["id"] as? String
                                self.teamsDictionary.setValue(secTeam, forKey: (team["id"] as? String)!)
                                //print("Team Name is: \(secTeam.teamName)")
                                return secTeam
                            }
                            
                            
                        }
                    }
                }  else {
                    
                    let teams = conference["teams"] as! [AnyObject]
                    for team in teams {
                        if (team["id"] as? String == teamID) {
                            let newTeam = Team()
                            newTeam.teamName = team["name"] as? String
                            newTeam.teamMarket = team["market"] as? String
                            newTeam.teamID = team["id"] as? String
                            self.teamsDictionary.setValue(newTeam, forKey: (team["id"] as? String)!)
                            //print("Team Name is: \(secTeam.teamName)")
                            let endTime = Date()
                            //print(endTime.timeIntervalSinceDate(startTime))
                            return newTeam
                        }
                    }
                }
            
        }
        return Team()
    }
    
    func getTeamSchedule(_ teamID: String) {
        
        let urlString = "https://api.sportradar.us/ncaafb-t1/2016/REG/schedule.json?api_key=6aeuunrjq3yrsjz9v6u8jfft"
        let url = URL(string: urlString)
        
        
        let task = session!.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            let startTime = Date()
            var jsonResult = NSDictionary()
            //NSThread.sleepForTimeInterval(5)

            if (error != nil) {
                print("Ooops! Something went wrong!")
            }
            
            do {
                print("Running Serialization")
                jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                //---get the path of the Documents folder---
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.allDomainsMask, true)
                let documentsDirectory = paths.first! as NSString
                
                //---full path of file to save in---
                let filePath = documentsDirectory.appendingPathComponent("AllGames.json")
                
                //jsonResult.writeToFile(filePath, atomically: true)
                
                
            } catch _ {
                print("Error downloading schedule information")
            }
            if (data == nil) { print("No Data") }
            
            let weeksArray = jsonResult["weeks"] as! [AnyObject]
            for week in weeksArray {
                let gamesArray = week["games"] as! [AnyObject]
                for game in gamesArray {
                    if (game["home"] as! String == teamID) || (game["away"] as! String == teamID) {
                        let currentHomeTeam: Team = self.findTeamFromID(game["home"] as! String)
                        let currentAwayTeam: Team = self.findTeamFromID(game["away"] as! String)
                        let weekNumber = week["number"] as! Int
                        let gameVenue = game["venue"] as! NSDictionary
                        let gameCity = gameVenue["city"] as! String
                        let gameState = gameVenue["state"] as! String
                        
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        let dateFromString = df.date(from: (game["scheduled"] as? String)!)
                        let df2 = DateFormatter()
                        df2.dateFormat = "E, MMM. d | h:mm a"
                        let dateString = df2.string(from: dateFromString!)
                        
                        let endTime = Date()
                        let runningTime = endTime.timeIntervalSince(startTime)
                        
                        self.displayString = self.displayString + "Home Team: \(currentHomeTeam.teamMarket) \(currentHomeTeam.teamName) \r\nAway Team: \(currentAwayTeam.teamMarket) \(currentAwayTeam.teamName) \r\nLocation: \(gameCity), \(gameState)\r\nDate: \(dateString)  |  Week Number: \(weekNumber.description)\r\n"
                        self.displayString = self.displayString + "Search Time: \(String(format: "%.4f", runningTime)) seconds \r\n"
                        self.displayString = self.displayString + " \r\n"
                        
                        print("Home Team: \(currentHomeTeam.teamMarket) \(currentHomeTeam.teamName) \r\nAway Team: \(currentAwayTeam.teamMarket) \(currentAwayTeam.teamName) \r\nLocation: \(gameCity), \(gameState)\r\nDate: \(dateString)  |  Week Number: \(weekNumber.description)")
                        print("Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
                    
                    }
                }
            }
            let endTime = Date()
            let runningTime = endTime.timeIntervalSince(startTime)
            print("Running Time: \(runningTime)")
            
            let mainQueue = OperationQueue.main
            mainQueue.addOperation({ 
                self.queue.waitUntilAllOperationsAreFinished()
                let endTime = Date()
                let runningTime = endTime.timeIntervalSince(startTime)
                print("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
                self.searchTimeLabel.isHidden = false
                self.searchTimeLabel.stringValue = ("Full Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
                self.outputTextView.string = self.displayString
            })
            
            
            })
        task.resume()
        
        
    }
    
    func TeamScheduleFromFile(_ teamID: String) {
        
        let path = Bundle.main.path(forResource: "AllGames", ofType: "json")
        let jsonResult = NSDictionary(contentsOfFile: path!)
        
        let weeksArray = jsonResult!["weeks"] as! [AnyObject]
        for week in weeksArray {
            let startTime = Date()
            let gamesArray = week["games"] as! [AnyObject]
            for game in gamesArray {
                if (game["home"] as! String == teamID) || (game["away"] as! String == teamID) {
                    let currentHomeTeam: Team = self.findTeamFromID(game["home"] as! String)
                    let currentAwayTeam: Team = self.findTeamFromID(game["away"] as! String)
                    let weekNumber = week["number"] as! Int
                    var gameCity = " "
                    var gameState = " "
                    if let gameVenueTemp = game["venue"] as? NSDictionary {
                        gameCity = (gameVenueTemp["city"] as! String)
                        //gameState = (gameVenueTemp["state"] as! String)
                        if let tempState = gameVenueTemp["state"] as? String {
                            gameState = tempState
                        }
                    } else {
                        gameCity = " "
                        gameState = " "
                    }
                    //let gameVenue = game["venue"] as! NSDictionary
                    
                    
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    let dateFromString = df.date(from: (game["scheduled"] as? String)!)
                    let df2 = DateFormatter()
                    df2.dateFormat = "E, MMM. d | h:mm a"
                    let dateString = df2.string(from: dateFromString!)
                    
                    let endTime = Date()
                    _ = endTime.timeIntervalSince(startTime)
                    
                    displayString = displayString + "Home Team: \(currentHomeTeam.teamMarket) \(currentHomeTeam.teamName) \r\nAway Team: \(currentAwayTeam.teamMarket) \(currentAwayTeam.teamName) \r\nLocation: \(gameCity), \(gameState)\r\nDate: \(dateString)  |  Week Number: \(weekNumber.description)\r\n"
                    //displayString = displayString.stringByAppendingString("Search Time: \(String(format: "%.4f", runningTime)) seconds \r\n")
                    displayString = displayString + " \r\n"
                    
                    print("Home Team: \(currentHomeTeam.teamMarket) \(currentHomeTeam.teamName) \r\nAway Team: \(currentAwayTeam.teamMarket) \(currentAwayTeam.teamName) \r\nLocation: \(gameCity), \(gameState)\r\nDate: \(dateString)  |  Week Number: \(weekNumber.description)")
                    //print("Search Time: \(String(format: "%.4f", runningTime)) seconds\n")
                }
            }
        }
    }
    
    func populateAllTeamsArray() {
        var foundTeam = false
        let startTime = Date()
        let path = Bundle.main.path(forResource: "AllTeams", ofType: "json")
        let jsonResult = NSDictionary(contentsOfFile: path!)
        
        let conferencesArray = jsonResult!["conferences"] as! [AnyObject]
        for conference in conferencesArray {
            let conferenceId = conference["id"] as? String
            let conferenceName = conference["name"] as? String
            if let _ = conference["subdivisions"] as? [AnyObject] {
                let subdivisions = conference["subdivisions"] as! [AnyObject]
                for subdivision in subdivisions {
                    let subdivisionId = subdivision["id"] as? String
                    let subdivisionName = subdivision["name"] as? String
                    let subdivisionTeams = subdivision["teams"] as! [AnyObject]
                    for team in subdivisionTeams {
                        
                            let newTeam = Team()
                            newTeam.teamName = team["name"] as? String
                            newTeam.teamMarket = team["market"] as? String
                            newTeam.teamID = team["id"] as? String
                            allTeams.append(newTeam)
                            //print("Team Name is: \(secTeam.teamName)"
                    }
                }
            }  else {
                
                let teams = conference["teams"] as! [AnyObject]
                for team in teams {
                        let newTeam = Team()
                        newTeam.teamName = team["name"] as? String
                        newTeam.teamMarket = team["market"] as? String
                        newTeam.teamID = team["id"] as? String
                        allTeams.append(newTeam)
                        //print("Team Name is: \(secTeam.teamName)")
                        let endTime = Date()
                        //print(endTime.timeIntervalSinceDate(startTime))
                        
                }
            }
            
        }
        print("All Teams Array Count: \(allTeams.count)")
    }

}

