//
//  Model.swift
//  ShazamClone
//
//  Created by John Holland on 8/13/26.
//

import Foundation
import MediaPlayer

func titleCase(_ text: String) -> String {
    let minorWords: Set<String> = [
        "a", "an", "the",
        "and", "but", "or", "nor",
        "for", "so", "yet",
        "as", "at", "by", "in", "of", "on", "to"
    ]

    let words = text.split(separator: " ", omittingEmptySubsequences: true)

    return words.enumerated().map { index, word in
        let lowerWord = word.lowercased()

        // Always capitalize the first and last words.
        if index == 0 || index == words.count - 1 {
            return lowerWord.prefix(1).uppercased() + lowerWord.dropFirst()
        }

        // Leave minor words lowercase.
        if minorWords.contains(lowerWord) {
            return lowerWord
        }

        // Capitalize the first letter of major words.
        return lowerWord.prefix(1).uppercased() + lowerWord.dropFirst()
    }.joined(separator: " ")
}
public class WikipediaModel : ObservableObject {
    @Published var currentTitle = "Nothing Playing"
    @Published var currentArtist = "Nothing Playing"
    @Published var currentAlbum = "No Album"
    
    @Published var currentTitleForWiki = "initial"
    @Published var currentArtistForWiki = "initial_artist"
    @Published var currentAlbumForWiki = "inital_album"
    
    @Published var currentTitleURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    @Published var currentArtistURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    @Published var currentAlbumURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    
    let  safeUrl = URL(string:"https://en.wikipedia.org")!
   
    public var wikiUrl =  "https://en.wikipedia.org/wiki/"
    
    public var wikiUrlSearch = "https://en.wikipedia.org/"
    
    @Published var canOpenArtist = true
    @Published var canOpenTitle = true
    @Published var canOpenAlbum = true
    
    func checkIfWikiCanOpen(url: URL) async  throws ->Bool {
        let url = url
        debugPrint(url)
        URLSession.initialize()
        let (_, response) = try await URLSession.shared.data(from: url)
        
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            debugPrint(statusCode)
            debugPrint(response)
            if (statusCode == 404 || statusCode == 302) {
                return false
            }
            else {
                return  true
            }
        }
        // something bad happened
        return false
    }
    
    
    func buildSearchURL(searchString:String) -> String {
        
        return wikiUrlSearch + "?search=" + fixStringForSearchURL(input: searchString) + "&title=Special:Search&profile=advanced&fulltext=1&ns0=1"
        
     
    }
func checkAndAdjustWikiUrls() async throws {
        debugPrint("entering checkAndAdjustWikiUrls", currentAlbum)
        
           
        
        
        debugPrint("trying initial artist URL")
        do {
            canOpenArtist = try await checkIfWikiCanOpen(url: currentArtistURLForWiki)
        } catch {
            debugPrint("error in checkifWikiCanopen initial artist URL")
        }
        if (!canOpenArtist) {
            Swift.debugPrint("modifying artist with title case")
            // try with title case
            
            currentArtist = titleCase(currentArtist)
            let currentArtistForWiki = fixStringForDirectURL(input:cleanUpStringWithRegexes(input: currentArtist))
            currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
            Swift.debugPrint("trying title case artist URL")
            do {
                
                
                canOpenArtist = try await checkIfWikiCanOpen(url: currentArtistURLForWiki)
            }
            catch {
               debugPrint("error in checkifWikiCanopen title case artist URL")
           }
            if (!canOpenArtist) {
                Swift.debugPrint("creating artist search URL")
                // try and use search URL
                debugPrint("Artist Search URL:" + buildSearchURL(searchString: currentArtist))
                currentArtistURLForWiki = URL(string:buildSearchURL(searchString: currentArtist)) ?? safeUrl
                Swift.debugPrint("trying search URL for artist")
                do {
                    canOpenArtist = try await checkIfWikiCanOpen(url:currentArtistURLForWiki)
                }
  
                    catch {
                       debugPrint("error in checkifWikiCanopen search artist URL")
                   }
                
            }
            
        }
        debugPrint("trying initial title URL")
        do {
            canOpenTitle = try await checkIfWikiCanOpen(url: currentTitleURLForWiki)
        }
        catch  let error {
            debugPrint("error in checkIfWikiCanOpen initial title URL:", error.localizedDescription)
        }
        if (!canOpenTitle) {
            debugPrint("modifying title with title case")
            // try with title case
            currentTitle = titleCase(currentTitle)
            let currentTitleForWiki = fixStringForDirectURL(input: cleanUpStringWithRegexes(input:currentTitle))
            currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
            debugPrint("trying title case title URL")
            canOpenTitle = try await checkIfWikiCanOpen(url: currentTitleURLForWiki)
            if (!canOpenTitle) {
                debugPrint("creating title search URL")
                
                // try and use search URL
                debugPrint("Title Search URL:" + buildSearchURL(searchString: currentTitle))
                currentTitleURLForWiki = URL(string:buildSearchURL(searchString: currentTitle)) ?? safeUrl
                debugPrint("trying search URL for title " + currentTitleURLForWiki.absoluteString)
                canOpenTitle = try await checkIfWikiCanOpen(url:currentTitleURLForWiki)
            }
        }
    debugPrint("trying initial album URL")
    do {
        canOpenAlbum = try await checkIfWikiCanOpen(url: currentAlbumURLForWiki)
    }
    catch  let error {
        debugPrint("error in checkIfWikiCanOpen initial album URL:", error.localizedDescription)
    }
    if (!canOpenAlbum) {
        debugPrint("modifying album with title case")
        // try with title case
        currentAlbum = titleCase(currentAlbum)
        let currentAlbumForWiki = fixStringForDirectURL(input: cleanUpStringWithRegexes(input:currentAlbum))
        currentAlbumURLForWiki = URL(string:wikiUrl + currentAlbumForWiki) ?? safeUrl
        debugPrint("trying title case album URL")
        canOpenAlbum = try await checkIfWikiCanOpen(url: currentAlbumURLForWiki)
        if (!canOpenAlbum) {
            debugPrint("creating album search URL")
            
            // try and use search URL
            debugPrint("Album Search URL:" + buildSearchURL(searchString: currentAlbum))
            currentAlbumURLForWiki = URL(string:buildSearchURL(searchString: currentAlbum)) ?? safeUrl
            debugPrint("trying search URL for album " + currentAlbumURLForWiki.absoluteString)
            canOpenAlbum = try await checkIfWikiCanOpen(url:currentAlbumURLForWiki)
        }
    }
        debugPrint("returning from checkAndAdjustWikiUrls")
    }
    func cleanUpStringWithRegexes(input:String) ->String {
        var output = input
        //parens with years
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*\\d{4}.*\\)", options:[])
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }
        //parens with edition
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*\\edition.*\\)", options:[])
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }
        //parens with "mix"
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*mix.*\\)", options: .caseInsensitive)
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }
        //parens with "version"
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*version.*\\)", options: .caseInsensitive)
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }
        //parens with "remastered"
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*remastered.*\\)", options: .caseInsensitive)
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }
        //parens with "feat" (i.e. "featured")
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*feat.*\\)", options: .caseInsensitive)
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            output = input
            debugPrint("regex failed")
        }

        
        
        
        
        do {
            let regex = try  NSRegularExpression(pattern:"\\[.*\\]", options:[])
            
            output = regex.stringByReplacingMatches(in: output,options:[], range: NSRange(output.startIndex..., in: output), withTemplate: "")
        } catch  {
            debugPrint("2nd regex failed")
        }
        return output
    }
    func fixStringForDirectURL(input:String)->(_:String) {
        
        var output = input
        
        output.replace(" ", with: "_")
        return output.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? "error encoding"
    }
    func fixStringForSearchURL(input:String)->(_:String) {
        
        var output = input
        
        output.replace(" ", with: "+")
        output.replace("&", with: "%26")
        return output
    }
    
    
func populateCurrPlaying(title:String, artist:String, album:String) {
    (currentTitle, currentArtist, currentAlbum)  = (title, artist,album)
          
        let currentTitleForWiki = fixStringForDirectURL(input: cleanUpStringWithRegexes(input:currentTitle))
        let currentArtistForWiki = fixStringForDirectURL(input:cleanUpStringWithRegexes(input: currentArtist))
    let currentAlbumForWiki =  fixStringForDirectURL(input:cleanUpStringWithRegexes(input: currentAlbum))
        
        
        currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
        currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
    currentAlbumURLForWiki = URL(string:wikiUrl + currentAlbumForWiki) ?? safeUrl
        Task.synchronous(operation:  {
            do {
                try await  self.checkAndAdjustWikiUrls()
            }
            catch let error{
                debugPrint("error checking wikipedia urls", error )
            }
            
        }
                         )
        debugPrint("returning from populateCurrPlaying")
    }
    
}
extension Task where Failure == Error {
    /// Performs an async task in a sync context.
    ///
    /// - Note: This function blocks the thread until the given operation is finished. The caller is responsible for managing multithreading.
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        let semaphore = DispatchSemaphore(value: 0)

        Task(priority: priority) {
            defer { semaphore.signal() }
            return try await operation()
        }

        semaphore.wait()
    }
}
