//
//  RoomsViewController.swift
//  MatrixApp
//
//  Created by Oliver Lumby on 18/01/2017.
//  Copyright © 2017 Oliver Lumby. All rights reserved.
//

import UIKit
import MatrixSDK

class RoomsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var rooms: [MatrixRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = AppColors.darkBlue
        self.navigationController?.navigationBar.setBottomBorderColor(color: AppColors.darkBlue, height: 1)
        
        if MatrixAccount.accounts().isEmpty {
            self.performSegue(withIdentifier: "showAuth", sender: self)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(matrixSessionStateDidChange), name: Notification.Name("kMXSessionStateDidChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(matrixSessionDidSync), name: Notification.Name("kMXSessionDidSyncNotification"), object: nil)
    }

    func matrixSessionStateDidChange(notification: Notification) {
        if let session = notification.object as? MXSession {
            self.loadRooms(session: session)
        }
    }
    
    func matrixSessionDidSync(notification: Notification) {
        if let session = notification.object as? MXSession {
            self.loadRooms(session: session)
        }
    }
    
    func loadRooms(session: MXSession) {
        self.rooms = session.rooms(withTag: kMXSessionNoRoomTag).map({ (room) -> MatrixRoom in
            return MatrixRoom(room: room)
        }).sorted(by: { (a, b) -> Bool in
            return a.lastEvent().event.age < b.lastEvent().event.age
        })
        self.tableView.reloadData()
    }

}

extension RoomsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomTableViewCell", for: indexPath) as! RoomTableViewCell
        
        let room = self.rooms[indexPath.row]

        cell.setCell(room: room)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRoom", sender: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoom" {
            if let vc = segue.destination as? RoomViewController, let indexPath = sender as? IndexPath {
                vc.room = self.rooms[indexPath.row]
            }
        }
    }
    
}
