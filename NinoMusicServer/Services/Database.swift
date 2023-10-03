//
//  Database.swift
//  NinoMusicServer
//
//  Created by Luiz Guilherme Machado on 05/10/22.
//

import Foundation
import SQLite3

class Database {
    
    private let colRowId = "RowId"
    
    private let databasePath: String?
    private var database: OpaquePointer?
    
    private let tableMusics = "Musics"
    private let colFilePath = "FilePath"
    private let colIdArtist = "IdArtist"
    private let colTrack = "Track"
    private let colIdAlbum = "IdAlbum"
    private let colTitle = "Title"
    private let colIdGenre = "IdGenre"
    
    private let tableArtists = "Artists"
    private let colArtist = "Artist"
    
    private let tableAlbuns = "Albuns"
    private let colAlbum = "Album"
    private let colYear = "Year"
    
    private let tableGenres = "Genres"
    private let colGenre = "Genre"
    
    init (databasePath: String) {
        self.databasePath = databasePath
        if sqlite3_open(self.databasePath, &database) == SQLITE_OK {
            CreateTableMusics()
            CreateTableArtists()
            CreateTableAlbuns()
            CreateTableGenres()
        } else {
        }
    }
    
    func AddMusic(filePath: String, musicTitle: String, artist: String, album: String, year: Int, track: Int, genre: String) -> Bool{
        let idArtist = GetRowId(table: self.tableArtists, column1: "Artist", value1: artist)
        let idAlbum = GetRowId(table: self.tableAlbuns, column1: "Album", value1: album, column2: "Year", value2: String(year))
        let idGenre = GetRowId(table: self.tableGenres, column1: "Genre", value1: genre)
        var result = false
        
        var queryStatement: OpaquePointer?
        let sql = "INSERT INTO \(self.tableMusics) (\(self.colFilePath), \(self.colIdArtist), \(self.colTrack), \(self.colIdAlbum), \(self.colTitle), \(self.colIdGenre)) VALUES (\"\(filePath)\", \(idArtist), \(track), \(idAlbum), \"\(musicTitle.replacingOccurrences(of: "\"", with: "'"))\", \(idGenre) );"
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                result = true
            }
        }
        sqlite3_finalize(queryStatement)
        return result
    }
    
    func listMusics(completion: @escaping ([Music]?) -> ()) {
        let sql = """
        SELECT
           \(self.tableMusics).\(self.colRowId),
           \(self.tableArtists).\(self.colArtist),
           \(self.tableMusics).\(self.colTitle),
           \(self.tableMusics).\(self.colTrack),
           \(self.tableAlbuns).\(self.colAlbum),
           \(self.tableGenres).\(self.colGenre),
           \(self.tableAlbuns).\(self.colYear),
           \(self.tableMusics).\(self.colFilePath)
        FROM
           \(self.tableMusics)
           INNER JOIN \(self.tableArtists) ON \(self.tableArtists).\(self.colRowId) = \(self.tableMusics).IdArtist
           INNER JOIN \(self.tableAlbuns) ON \(self.tableAlbuns).\(self.colRowId) = \(self.tableMusics).IdAlbum
           INNER JOIN \(self.tableGenres) ON \(self.tableGenres).\(self.colRowId) = \(self.tableMusics).IdGenre
        ORDER BY
           \(self.tableMusics).\(self.colTitle),
           \(self.tableArtists).\(self.colArtist)
        """
        var queryStatement: OpaquePointer?
        var musicList = [Music]()
        
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let artist = String(cString: sqlite3_column_text(queryStatement, 1))
                let album = String(cString: sqlite3_column_text(queryStatement, 4))
                let year = String(cString: sqlite3_column_text(queryStatement, 6))
                let track = Int(sqlite3_column_int(queryStatement, 3))
                let musicTitle = String(cString: sqlite3_column_text(queryStatement, 2))
                let genre = String(cString: sqlite3_column_text(queryStatement, 5))
                let filePath = String(cString: sqlite3_column_text(queryStatement, 7))
                
                musicList.append(Music(artist: artist,
                                       album: album,
                                       year: year,
                                       track: track,
                                       musicTitle: musicTitle,
                                       genre: genre,
                                       filePath: filePath))
            }
        }
        sqlite3_finalize(queryStatement)
        completion(musicList)
    }
    
    func listMusicsRemote(completion: @escaping ([MusicRemote]?) -> ()) {
        let sql = """
        SELECT
           \(self.tableMusics).\(self.colRowId),
           \(self.tableArtists).\(self.colArtist),
           \(self.tableMusics).\(self.colTitle),
           \(self.tableMusics).\(self.colTrack),
           \(self.tableAlbuns).\(self.colAlbum),
           \(self.tableGenres).\(self.colGenre),
           \(self.tableAlbuns).\(self.colYear)
        FROM
           \(self.tableMusics)
           INNER JOIN \(self.tableArtists) ON \(self.tableArtists).\(self.colRowId) = \(self.tableMusics).IdArtist
           INNER JOIN \(self.tableAlbuns) ON \(self.tableAlbuns).\(self.colRowId) = \(self.tableMusics).IdAlbum
           INNER JOIN \(self.tableGenres) ON \(self.tableGenres).\(self.colRowId) = \(self.tableMusics).IdGenre
        ORDER BY
           \(self.tableMusics).\(self.colTitle),
           \(self.tableArtists).\(self.colArtist)
        """
        var queryStatement: OpaquePointer?
        var musicListRemote = [MusicRemote]()
        
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let artist = String(cString: sqlite3_column_text(queryStatement, 1))
                let album = String(cString: sqlite3_column_text(queryStatement, 4))
                let year = String(cString: sqlite3_column_text(queryStatement, 6))
                let track = Int(sqlite3_column_int(queryStatement, 3))
                let musicTitle = String(cString: sqlite3_column_text(queryStatement, 2))
                let genre = String(cString: sqlite3_column_text(queryStatement, 5))
                
                musicListRemote.append(MusicRemote(id: id,
                                                   artist: artist,
                                                   album: album,
                                                   year: year,
                                                   track: track,
                                                   musicTitle: musicTitle,
                                                   genre: genre))
            }
        }
        sqlite3_finalize(queryStatement)
        completion(musicListRemote)
    }
    
    func musicExists(filePath: String) -> Bool {
        let sql = """
        SELECT
           *
        FROM
           \(self.tableMusics)
        WHERE
           \(self.colFilePath) = \"\(filePath)\"
        """
        var queryStatement: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                count += 1
            }
        }
        sqlite3_finalize(queryStatement)
        return count > 0
    }
    
    func getMusicById(id: Int, completion: @escaping (String?) -> ()) {
        let sql = """
        SELECT
           \(self.tableMusics).\(self.colFilePath)
        FROM
           \(self.tableMusics)
        WHERE
           \(self.colRowId) = \(id)
        """
        var queryStatement: OpaquePointer?
        var result = ""
        
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                result = String(cString: sqlite3_column_text(queryStatement, 0))
            }
        }
        sqlite3_finalize(queryStatement)
        completion(result)
    }
    
    func closeDatabase() {
        if sqlite3_close(self.database) != SQLITE_OK {
            print("error closing database")
        }
    }
    
    func GetRowId(table: String, column1: String, value1: String, column2: String = "", value2: String = "") -> Int {
        var queryStatement: OpaquePointer?
        var sql = ""
        if column2 != "" && value2 != "" {
            sql = "SELECT \(self.colRowId) FROM \(table) WHERE \(column1) = \"\(value1.replacingOccurrences(of: "\"", with: "'"))\" AND \(column2) = \"\(value2.replacingOccurrences(of: "\"", with: "'"))\";"
        } else {
            sql = "SELECT \(self.colRowId) FROM \(table) WHERE \(column1) = \"\(value1.replacingOccurrences(of: "\"", with: "'"))\""
        }
        var result = 0
        if sqlite3_prepare_v2(self.database, sql, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                result = Int(sqlite3_column_int(queryStatement, 0))
            } else {
                if column2 != "" && value2 != "" {
                    sql = "INSERT INTO \(table) (\(column1), \(column2)) VALUES (\"\(value1.replacingOccurrences(of: "\"", with: "'"))\", \"\(value2.replacingOccurrences(of: "\"", with: "'"))\");"
                } else {
                    sql = "INSERT INTO \(table) (\(column1)) VALUES (\"\(value1.replacingOccurrences(of: "\"", with: "'"))\");"
                }
                if sqlite3_exec(self.database, sql, nil, nil, nil) == SQLITE_OK {
                    result = Int(sqlite3_last_insert_rowid(self.database))
                }
            }
        }
        sqlite3_finalize(queryStatement)
        return result
    }
    
    private func CreateTable(sql: String) -> Bool {
        var createTableStatement: OpaquePointer?
        var result = false
        if sqlite3_prepare_v2(self.database, sql, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                result = true
            }
        }
        sqlite3_finalize(createTableStatement)
        return result
    }
    
    private func CreateTableMusics() {
        let sqlCreateTableMusics = """
        CREATE TABLE IF NOT EXISTS \(self.tableMusics) (
        \(self.colFilePath) CHAR(255) PRIMARY KEY NOT NULL,
        \(self.colIdArtist) INT,
        \(self.colIdAlbum) INT,
        \(self.colTrack) INT,
        \(self.colTitle) CHAR(255),
        \(self.colIdGenre) INT);
        """
        if CreateTable(sql: sqlCreateTableMusics) {
            
        }
    }
    
    private func CreateTableArtists() {
        let sqlCreateTableArtists = """
        CREATE TABLE IF NOT EXISTS \(self.tableArtists) (
        \(self.colArtist) CHAR(255) PRIMARY KEY NOT NULL);
        """
        if CreateTable(sql: sqlCreateTableArtists) {
            
        }
    }
    
    private func CreateTableAlbuns() {
        let sqlCreateTableAlbuns = """
        CREATE TABLE IF NOT EXISTS \(self.tableAlbuns) (
        \(self.colAlbum) CHAR(255) PRIMARY KEY NOT NULL,
        \(self.colYear) CHAR(4));
        """
        if CreateTable(sql: sqlCreateTableAlbuns) {
            
        }
    }
    
    private func CreateTableGenres() {
        let sqlCreateTableGenres = """
        CREATE TABLE IF NOT EXISTS \(self.tableGenres) (
        \(self.colGenre) CHAR(255) PRIMARY KEY NOT NULL);
        """
        if CreateTable(sql: sqlCreateTableGenres) {
            
        }
    }
}
