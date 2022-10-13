//
//  ViewController.swift
//  NinoMusicServer
//
//  Created by Luiz Guilherme Machado on 01/09/22.
//

import Cocoa
import AVFAudio

enum ChanelMeter {
    case right
    case left
}

class ViewController: NSViewController {
    
    private let updateInterval = 0.05
    
    var musicsListViewModel: MusicsListViewModel?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnPrevMusic: NSButton!
    @IBOutlet weak var btnPlayPauseMusic: NSButton!
    @IBOutlet weak var btnStopMusic: NSButton!
    @IBOutlet weak var btnNextMusic: NSButton!
    
    @IBOutlet weak var leftMeter: NSLevelIndicator!
    @IBOutlet weak var rightMeter: NSLevelIndicator!
    
    var player: AVAudioPlayer?
    private var timer: Timer?
    
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
    
    @IBAction func openDirClick(_ sender: Any) {
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
    
    @IBAction func playPauseMusicClick(_ sender: Any) {
        if let url = URL(string: self.musicsListViewModel?.musicAtIndex(self.tableView.selectedRow).filePath ?? "") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.isMeteringEnabled = true
                player.play()
                
                if player.isPlaying {
                    self.leftMeter.floatValue = 0.0
                    self.rightMeter.floatValue = 0.0
                    
                    timer = Timer.scheduledTimer(timeInterval: updateInterval,
                                                 target: self,
                                                 selector: #selector(self.updateMeters),
                                                 userInfo: nil,
                                                 repeats: true)
                    
                    btnPrevMusic.isEnabled = true
                    btnStopMusic.isEnabled = true
                    btnNextMusic.isEnabled = true
                }
                
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    @IBAction func stopMusicClick(_ sender: Any) {
        if let player = self.player {
            if player.isPlaying {
                guard timer != nil, timer!.isValid else {
                    return
                }
                timer?.invalidate()
                timer = nil
                
                player.stop()
                btnPrevMusic.isEnabled = false
                btnStopMusic.isEnabled = false
                btnNextMusic.isEnabled = false
                
                self.leftMeter.floatValue = 0.0
                self.rightMeter.floatValue = 0.0
            }
        }
    }
    
    @objc private func updateMeters() {
        if let player = self.player {
            player.updateMeters()
            self.leftMeter.floatValue = (player.peakPower(forChannel: 0) + 160.0)
            self.rightMeter.floatValue = (player.peakPower(forChannel: 1) + 160.0)
            print(" \(player.peakPower(forChannel: 0))")
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
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let rows = self.musicsListViewModel?.numberOfRowsInSection(1) {
            if row >= 0 && row < rows {
                btnPlayPauseMusic.isEnabled = true
            }
        }
        return true
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.musicsListViewModel?.numberOfRowsInSection(1) ?? 0
    }
}

