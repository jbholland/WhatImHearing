//
//  SongDetailView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI

struct SongDetailView: View {
    var song: Song
    var wikipediaModel:WikipediaModel
    @State private var showArtistCantOpen = false
    @State private var showTitleCantOpen = false
    @Environment(\.openURL) private var openURL
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    AsyncImage(url: song.artworkUrl) { phase in
                        if let image = phase.image {
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(maxHeight: 200)
                                 .clipped()
                        } else if phase.error != nil {
                            Color.blue
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 200, alignment: .center)

                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(Color.black)

                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(Color.black)

                  
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                    if let appleMusicUrl = song.appleMusicUrl {
                        Link(destination: appleMusicUrl, label: {
                            Text("Play on Apple Music ")
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width - 64, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 10).fill(Color.red)
                                        .shadow(radius: 1)
                                )
                        })
                        
                        Text("Wikipedia:") .bold().font(.title).multilineTextAlignment(.center)
                        Button(wikipediaModel.currentTitle) {
                            if  wikipediaModel.canOpenTitle{
                                openURL(wikipediaModel.currentTitleURLForWiki)
                            } else {
                                showTitleCantOpen = true
                                print("can't open this  song")
                            }
                        }.font(.title)
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
                                    print("can't open this  artist")
                                }
                            }.font(.title)
                                .alert(Text("Wikipedia cannot find this artist"), isPresented: $showArtistCantOpen){
                                    Button("OK", role: .cancel) {
                                        showArtistCantOpen = false
                                    }
                                }
                            .buttonStyle(.borderedProminent)
                           
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.8), radius: 0.8)
                )
                .padding()
            }
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
                appleMusicUrl: URL(string: "https://music.apple.com/us/album/here-comes-the-sun/1441164416?i=1441164670")
            )
            , wikipediaModel: WikipediaModel()
            
        )
        Text("")
    }
}
