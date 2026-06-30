//
//  Model.swift
//  WhatsPlaying
//
//  Created by John Holland on 5/3/23.
//

import Foundation
import MediaPlayer
public class Model : ObservableObject {
    
    @Published var currentTitle = "Nothing Playing"
    @Published var currentArtist = "Nothing Playing"
    @Published var currentAlbum = "Nothing Playing"
    @Published var currentTitleForWiki = "initial"
    @Published var currentArtistForWiki = "initial_artist"
    @Published var currentAlbumForWiki  = "initial_album"
    @Published var currentTitleURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    @Published var currentArtistURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    @Published var currentAlbumURLForWiki : URL  = URL(string:"https://www.wikipedia.org")!
    
    @Published var canOpenArtist = true
    @Published var canOpenTitle = true
    @Published var canOpenAlbum = true
    
    func checkIfWikiCanOpen(url: URL) async  throws ->Bool {
        let url = url
        let (_, response) = try await URLSession.shared.data(from: url)
        
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            print(statusCode)
            if (statusCode == 404) {
                return false
            }
            else {
                return  true
            }
        }
        // something bad happened
        return false
    }
    func checkWikiUrls() async throws {
        canOpenArtist = try await checkIfWikiCanOpen(url: currentArtistURLForWiki)
        canOpenTitle = try await checkIfWikiCanOpen(url: currentTitleURLForWiki)
        canOpenAlbum = try await checkIfWikiCanOpen(url: currentAlbumURLForWiki)
    }
    
    
    func cleanUpStringWithRegexes(input:String) ->String {
        var output = input
        
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*\\)$", options:[])
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            print("regex failed")
        }
        do {
            let regex = try  NSRegularExpression(pattern:"\\[.*\\]", options:[])
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            print("2nd regex failed")
        }
        return output
    }
    
    
    
    
    func fixStringForURL(input:String)->(_:String) {
        
        var output = input
        
        output.replace(" ", with: "_")
        return output.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? "error encoding"
    }
    func getCurrPlayingFromMusicPlayer()->(title:String, artist: String, album: String) {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            let titleString: String = nowPlayingItem.title ?? "no title value"
            
            return (
                titleString,nowPlayingItem.artist ?? "error getting artist",
                nowPlayingItem.albumTitle ?? "error getting album")
        } else {
            print("Nothing's playing")
            return ("Nothing", "Nobody", "No album")
        }
    }
    
    
    func populateCurrPlaying(wikiUrl:String, safeUrl:URL) {
        (currentTitle, currentArtist, currentAlbum)  = getCurrPlayingFromMusicPlayer()
          
        let currentTitleForWiki = fixStringForURL(input: cleanUpStringWithRegexes(input:currentTitle))
        let currentArtistForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentArtist))
        let currentAlbumForWiki = fixStringForURL(input:cleanUpStringWithRegexes(input: currentAlbum))
        
        currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
        currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
        currentAlbumURLForWiki = URL(string:wikiUrl + currentAlbumForWiki)  ?? safeUrl
        
    }
}
