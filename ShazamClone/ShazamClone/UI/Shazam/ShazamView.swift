//
//  ShazamView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//
import Combine
import RippleView
import SwiftUI
import MediaPlayer

struct ShazamView: View {
    @State private var shouldShowRippleView = false
    @State private var shouldShowRecordButton = false
    @State private var shouldShowStopButton = false
    @State private var shouldShowInfoAlert = false
    @State private var shouldShowIntroText = false
    @State private var shouldShowRecordPermissionAlert = false
    @State private var shouldShowNoResultView = false
    @State private var foundSong: Song!
    @State private var foundWikipediaModel = WikipediaModel()
    @State private var cancellables: Set<AnyCancellable> = []
    @EnvironmentObject private var shazamViewModel: ShazamViewModel
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
     
    let wikipath = ".wikipedia.org/wiki/"
    @State private var showArtistCantOpen = false
    @State private var showTitleCantOpen = false
    @State private var showAlbumCantOpen = false
    

    
    var body: some View {
        ZStack {
            Color.init(UIColor.systemBackground)

            ZStack {
                VStack(spacing: 20) {
                    if shouldShowIntroText {
                        Text("What I’m Hearing")
                            .frame(width: 250, height: 100, alignment: .center)
                            .font(.title2)
                    }
                    if shouldShowRippleView {
                        RippleView(
                            style: .solid,
                            rippleCount: 5,
                            tintColor: Color(UIColor.systemBlue),
                            timeIntervalBetweenRipples: 0.18
                        )
                        .padding(.horizontal, 48)
                    }
                    if shouldShowNoResultView {
                        
                        NoResultView {
                            onRecordButtonTapped()
                        }
                    }
                    

                    

                    if shouldShowRecordButton && !shouldShowNoResultView  {
                        recordButton
                            .alert(isPresented: $shouldShowRecordPermissionAlert, content: {
                                permissionAlert
                            })
     
                    }
                    if shouldShowStopButton {
                        stopButton
                    }
                    if shouldShowIntroText{
                        // this is localized
                        Text("Tap the record button to listen to music around you and find it on Wikipedia")
                            .frame(width: 300, height: 100, alignment: .center)
                        
                    }

                    if foundSong != nil {
                        VStack {
                            withAnimation(.easeInOut) {
                                SongDetailView(song: foundSong, wikipediaModel: foundWikipediaModel)
                            }
                            Spacer()
                            recordButton
                        }
                        .padding(.vertical, 64)
                    }

                }

                VStack {
                    HStack {
                        Spacer()
                        if (!shouldShowIntroText && !shouldShowStopButton ) {
                            infoButton
                                .alert(isPresented: $shouldShowInfoAlert, content: {
                                    infoAlert
                                })
                        }
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 32))

                    Spacer()
                }

           
            }
            .padding(EdgeInsets(top: 40, leading: 0, bottom: 10, trailing: 0))
        }
        .onAppear(perform: {
            bindViewModel()
        })
        .onDisappear(perform: {
            shazamViewModel.stopListening()
        })
        .ignoresSafeArea()
    }

    private var infoAlert: Alert {
        Alert(
            title: Text("What I’m Hearing"),
            message: Text("Tap the record button to listen to music around you and find it on Wikipedia"),
            dismissButton: .default(Text("OK"))
        )
    }

    private var permissionAlert: Alert {
        Alert(
            title: Text("Microphone access not allowed"),
            message: Text("Turn on microphone access to listen to music around you"),
            primaryButton: .default(
                Text("Go to Setting"),
                action: {
                    goToPermissionSettings()
                }
            ),
            secondaryButton: .cancel(Text("Close"))
        )
    }

    @ViewBuilder
    private var infoButton: some View {
        Button(action: {
            shazamViewModel.showInfo()
        }, label: {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .scaledToFit()
                .foregroundColor(Color(UIColor.label))
        })

    }

    @ViewBuilder
    private var recordButton: some View {
        Button(action: {
            onRecordButtonTapped()
        }, label: {
            Image(systemName: "mic")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 100, height: 100, alignment: .center)
                .background(
                    Circle().fill(Color(UIColor.systemBlue))
                        .shadow(radius: 1)
                )
        })
    }
    @ViewBuilder
        private var stopButton: some View {
            Button(action: {
                onStopButtonTapped()
                debugPrint("stop button pressed")
            }, label: {
                Image(systemName: "stop")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width:80, height: 80, alignment: .center)
                    .background(Circle().fill(Color(UIColor.systemRed))
                        .shadow(radius: 1)
                    )
            })
        }

    

    

    private func bindViewModel() {
        shazamViewModel.$viewState.sink { viewState in
            switch viewState {
            case .initial:
                shouldShowRippleView = false
                shouldShowRecordButton = true
                shouldShowNoResultView = false
                shouldShowIntroText = true
            case .recordingInProgress:
                shouldShowRecordButton = false
                shouldShowRippleView = true
                shouldShowNoResultView = false
                shouldShowIntroText = false
                foundSong = nil
            case .infoAlert:
                shouldShowInfoAlert = true
            case .recordPermissionSettingsAlert:
                shouldShowRecordPermissionAlert = true
            case .noResult:
                shouldShowRippleView = false
                shouldShowNoResultView = true
                shouldShowIntroText = false
                foundSong = nil
            case .result(let song, let wikipediaModel):
                withAnimation {
                    foundSong = song
                    foundWikipediaModel = wikipediaModel
                }
                shouldShowRippleView = false
                shouldShowRecordButton = false
                shouldShowStopButton = false
                shouldShowIntroText = false
            }
        }.store(in: &cancellables)
    }

    private func onRecordButtonTapped() {
        shouldShowStopButton = true
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if musicPlayer.playbackState == .playing {
            if let nowPlayingItem = musicPlayer.nowPlayingItem {
                debugPrint("nowPlayingItem.albumTitle", nowPlayingItem.albumTitle as Any)
                let song = Song(
                    title: nowPlayingItem.title ?? "",
                    artist: nowPlayingItem.artist ?? "",
                    genres: [],
                    artworkUrl: nil,
                    appleMusicUrl: nil,
                    mpMediaItemArtwork: nowPlayingItem.artwork,
                    album: nowPlayingItem.albumTitle ?? "No Album"
                )
                debugPrint("FROM APPLE MUSIC appleMusicUrl:", song.appleMusicUrl as Any)
                debugPrint("FROM APPLE MUSIC song.album", song.album)
              
                foundWikipediaModel = shazamViewModel.wikipediaModel
                shazamViewModel.populateFromMediaPlayer(song: song)
            }
        }
        else {
                
                shazamViewModel.startListening()
            }
    
    }
    private func onStopButtonTapped() {
        shazamViewModel.stopListening()
        shouldShowRippleView = false
        shouldShowStopButton = false
    }

    private func goToPermissionSettings() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

struct ShazamView_Previews: PreviewProvider {
    static var previews: some View {
        ShazamView()
    }
}
