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
    
    @Published var currentTitleForWiki = "initial"
    @Published var currentArtistForWiki = "initial_artist"
    
    @Published var currentTitleURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    @Published var currentArtistURLForWiki : URL = URL(string:"https://www.wikipedia.org")!
    
    let  safeUrl = URL(string:"https://en.wikipedia.org")!
   
    public var wikiUrl =  "https://en.wikipedia.org/wiki/"
    
    public var wikiUrlSearch = "https://en.wikipedia.org/"
    
    @Published var canOpenArtist = true
    @Published var canOpenTitle = true
    
    func checkIfWikiCanOpen(url: URL) async  throws ->Bool {
        let url = url
        debugPrint(url)
        URLSession.initialize()
        let (_, response) = try await URLSession.shared.data(from: url)
        
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            debugPrint(statusCode)
            debugPrint(response)
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
    
    
    func buildSearchURL(searchString:String) -> String {
        
        //https://en.wikipedia.org/w/index.php?search=i+think+ur+a+contra&title=Special:Search&ns0=1
       //https://en.wikipedia.org/w/index.php?search=I+Think+Ur+a+Contra&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1
       return wikiUrlSearch + "w/index.php?search=" + fixStringForSearchURL(input: searchString) + "&title=Special:Search&profile=advanced&fulltext=1&ns0=1"
        
     
    }
func checkAndAdjustWikiUrls() async throws {
        
        
           
        
        
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
                debugPrint("creating artist search URL")
                
                // try and use search URL
                debugPrint("Title Search URL:" + buildSearchURL(searchString: currentTitle))
                currentTitleURLForWiki = URL(string:buildSearchURL(searchString: currentTitle)) ?? safeUrl
                debugPrint("trying search URL for title " + currentTitleURLForWiki.absoluteString)
                canOpenTitle = try await checkIfWikiCanOpen(url:currentTitleURLForWiki)
            }
        }
        debugPrint("returning from checkAndAdjustWikiUrls")
    }
    func cleanUpStringWithRegexes(input:String) ->String {
        var output = input
        
        do {
            let regex = try  NSRegularExpression(pattern:"\\(.*\\)$", options:[])
            
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
        return output
    }
    
    
    func populateCurrPlaying(title:String, artist:String) {
        (currentTitle, currentArtist)  = (title, artist)
          
        let currentTitleForWiki = fixStringForDirectURL(input: cleanUpStringWithRegexes(input:currentTitle))
        let currentArtistForWiki = fixStringForDirectURL(input:cleanUpStringWithRegexes(input: currentArtist))

        
        currentTitleURLForWiki = URL(string:wikiUrl + currentTitleForWiki) ?? safeUrl
        currentArtistURLForWiki = URL(string:wikiUrl + currentArtistForWiki) ?? safeUrl
        Task {
            do {
                try await  self.checkAndAdjustWikiUrls()
            }
            catch let error{
                debugPrint("error checking wikipedia urls", error )
            }
            
        }
        debugPrint("returning from populateCurrPlaying")
    }
    
}
