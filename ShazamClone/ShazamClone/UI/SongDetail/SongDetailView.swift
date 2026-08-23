//
//  SongDetailView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI
import Foundation

struct SongDetailView: View {
    var song: Song
    var wikipediaModel:WikipediaModel
    @State private var showArtistCantOpen = false
    @State private var showTitleCantOpen = false
    @State private var showAlbumCantOpen = false
    @Environment(\.openURL) private var openURL
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    
                    
                    if song.artworkUrl != nil {
                        AsyncImage(url: song.artworkUrl) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxHeight: 200)
                                    .clipped()
                            } else if phase.error != nil {
                                Color(UIColor.systemBlue)
                            } else {
                                ProgressView()
                            }
                        }.frame(height: 200, alignment: .center)
                        
                    } else {
                        if  song.mpMediaItemArtwork != nil  {
                            let image = song.mpMediaItemArtwork!.image(at:CGSize(width: 500, height: 200))
                            
                            Image(uiImage: (image ?? UIImage(systemName:"photo"))!).resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 200)
                                .clipped()
                        }
                        else {
                            ZStack {
                                Color(UIColor.systemRed).frame(height:200, alignment: .center)
                                Text("Error getting artwork").foregroundStyle(Color(UIColor.systemYellow))                                .frame(width: 300, height: 100, alignment: .center)
                            }
                        }
                        
                    }
                    
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(Color(UIColor.label))
                        
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.label))
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                     if song.appleMusicUrl != nil {
                        if let appleMusicUrl = song.appleMusicUrl {
                            Link(destination: appleMusicUrl, label: {
                                Text("Play on Apple Music ")
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .frame(width: geometry.size.width - 64, height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemRed))
                                            .shadow(radius: 1)
                                    )
                            })
                        }
                    } else if song.album == "" { // if not a song retrieved from apple music
                        ZStack {
                            Color(UIColor.systemRed).frame(height:20, alignment: .center)
                            Text("Error getting AppleMusicLink").foregroundStyle(Color(UIColor.systemYellow))                                .frame(width: 300, height: 20, alignment: .center)
                        }
                    }
                    Text("Wikipedia:") .bold().font(.title).multilineTextAlignment(.center)
                    Button(wikipediaModel.currentTitle) {
                        if  wikipediaModel.canOpenTitle{
                            openURL(wikipediaModel.currentTitleURLForWiki)
                        } else {
                            showTitleCantOpen = true
                            debugPrint("can't open this song")
                        }
                    }.font(.headline)
                        .alert(Text("Wikipedia cannot find this song"), isPresented: $showTitleCantOpen){
                            Button("OK", role: .cancel) {
                                showTitleCantOpen = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    
                    
                    Button(wikipediaModel.currentArtist){
                        if  wikipediaModel.canOpenArtist{
                            openURL(wikipediaModel.currentArtistURLForWiki)
                        } else {
                            showArtistCantOpen = true
                            debugPrint("can't open this artist")
                        }
                    }.font(.headline)
                        .alert(Text("Wikipedia cannot find this artist"), isPresented: $showArtistCantOpen){
                            Button("OK", role: .cancel) {
                                showArtistCantOpen = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    
                    if wikipediaModel.currentAlbum != "" {
                        Button(wikipediaModel.currentAlbum){
                            if  wikipediaModel.canOpenAlbum{
                                openURL(wikipediaModel.currentAlbumURLForWiki)
                            } else {
                                showAlbumCantOpen = true
                                debugPrint("can't open this album")
                            }
                        }
                        .font(.headline)
                        .alert(Text("Wikipedia cannot find this album"), isPresented: $showAlbumCantOpen){
                            Button("OK", role: .cancel) {
                                showAlbumCantOpen = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        
                        .padding(.bottom)
                        
                    }
                    
                }
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color(UIColor.systemGray).opacity(0.8), radius: 0.8)
                )
                .padding()
            }
        }

    }


struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailView(
            song: Song(
                title: "Here Comes The Sun",
                artist: "The Beatles",
                genres: ["Rock"],
                artworkUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/46/5a/87/465a87e3-a042-06ae-c645-4bbf0bd26305/00602567713433.rgb.jpg/600x600bb.jpg"),
                appleMusicUrl: URL(string: "https://music.apple.com/us/album/here-comes-the-sun/1441164416?i=1441164670"), mpMediaItemArtwork: nil,
                album: "Album goes here"
            )
            , wikipediaModel: WikipediaModel()
            
        )
        Text("")
    }
}
