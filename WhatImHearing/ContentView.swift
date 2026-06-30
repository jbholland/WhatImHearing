//
//  ContentView.swift
//  WhatsPlaying
//
//  Created by John Holland on 4/28/23.
//

import SwiftUI
import MediaPlayer



func getPreferredLanguage(locale:Locale)->String {
    let langCode = String(locale.identifier.dropLast(3))
    return langCode
}




struct ContentView: View {
    
    @StateObject private var model = Model()
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    let safeUrl = URL(string:"https://en.wikipedia.org")!
    
    let wikipath = ".wikipedia.org/wiki/"
    @State private var showArtistCantOpen = false
    @State private var showTitleCantOpen = false
    @State private var showAlbumCantOpen = false
    @State private var wikiUrl =  "https://en.wikipedia.org/wiki/"
    
    
    
    
    var body: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("main_heading" , comment: "Wikipedia entries on what's playing:")).bold().font(.title).multilineTextAlignment(.center).padding()
                .onChange(of: scenePhase) {
                    newPhase in
                    Task {
                        try await model.checkWikiUrls()
                    }
                    if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .active {
                        print("Active")
                        wikiUrl =   "https://" + getPreferredLanguage(locale: locale) + wikipath
                        model.populateCurrPlaying(wikiUrl: wikiUrl, safeUrl: safeUrl)
                        } else if newPhase == .background {
                        print("Background")
                    }
                }
              Text(NSLocalizedString("song", comment:"Song:")).font(.title)
            Button(model.currentTitle) {
                if  model.canOpenTitle{
                    openURL(model.currentTitleURLForWiki)
                } else {
                    showTitleCantOpen = true
                    print("can't open this  song")
                }
            }.font(.title)
                .alert(NSLocalizedString("cannotFindSong", comment: "Wikipedia cannot find this song"), isPresented: $showTitleCantOpen){
                    Button("OK", role: .cancel) {
                        showTitleCantOpen = false
                    }
                }
            .buttonStyle(.borderedProminent)
            Text(NSLocalizedString("by", comment:"By:")).font(.title)
            Button(model.currentArtist) {
                if  model.canOpenArtist{
                    openURL(model.currentArtistURLForWiki)
                } else {
                    showArtistCantOpen = true
                    print("can't open this  artist")
                }
            }.font(.title)
                .alert(NSLocalizedString("cannotFindArtist", comment: "Wikipedia cannot find this artist"), isPresented: $showArtistCantOpen){
                    Button("OK", role: .cancel) {
                        showArtistCantOpen = false
                    }
                }
            .buttonStyle(.borderedProminent)
            Text(NSLocalizedString("album", comment:"Album:")).font(.title)
            Button(model.currentAlbum) {
                if  model.canOpenAlbum{
                    openURL(model.currentAlbumURLForWiki)
                } else {
                    showAlbumCantOpen = true
                    print("can't open this album")
                }
            }.font(.title)
                .alert(NSLocalizedString("cannotFindAlbum", comment: "Wikipedia cannot find this album"), isPresented: $showAlbumCantOpen){
                    Button("OK", role: .cancel) {
                        showAlbumCantOpen = false
                    }
                }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
