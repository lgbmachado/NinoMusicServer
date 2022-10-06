//
//  ViewController.swift
//  NinoMusicServer
//
//  Created by Luiz Guilherme Machado on 01/09/22.
//

import Cocoa
//import UIKit
//import UIAlertController

class ViewController: NSViewController {
    
    var musicsListViewModel: MusicsListViewModel?
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let musicDb = Database(databasePath: "/Users/nino/MusicDatabase.db")
        musicDb.listMusics { musicsList in
            if let musicsList = musicsList {
                self.musicsListViewModel = MusicsListViewModel(musics: musicsList)
                self.tableView.reloadData()
            }
        }
        musicDb.closeDatabase()
    }
    
    private func setup() {
        
    }
    
    @IBAction func opnDirClick(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title = "Selecione o diretório com as músicas"
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                let path: String = result!.path
                
                ListFileMusic().loadMusics(path: path) { musicsLoaded in
                    if let musicsLoaded = musicsLoaded {
                        print("👍 \(musicsLoaded) música(s) carregada(s)")
                        //                        let alert = UIAlertController(title: "Sign out?", message: "You can always access your content by signing back in", preferredStyle: UIAlertControllerStyle.alert)
                        //                        self.present(alert, animator: true)
                        let musicDb = Database(databasePath: "/Users/nino/MusicDatabase.db")
                        musicDb.listMusics { musicsList in
                            if let musicsList = musicsList {
                                self.musicsListViewModel = MusicsListViewModel(musics: musicsList)
                                self.tableView.reloadData()
                            }
                        }
                        musicDb.closeDatabase()
                    }
                }
            }
        } else {
            return
        }
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let currentMusic = self.musicsListViewModel?.musicAtIndex(row)
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColMusic") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelMusic"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = currentMusic?.title ?? ""
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColArtist") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelArtist"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = currentMusic?.artist ?? ""
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColAlbum") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelAlbum"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = currentMusic?.album ?? ""
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColYear") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelYear"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = String("\(currentMusic?.year ?? "")")
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColTrack") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelTrack"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = String("\(currentMusic?.track ?? 0)")
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColGenre") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelGenre"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = currentMusic?.genre ?? ""
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColFile") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idCelFile"), owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = currentMusic?.filePath ?? ""
            return cellView
        } else {
            
        }
        return nil
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.musicsListViewModel?.numberOfRowsInSection(1) ?? 0
    }
}

