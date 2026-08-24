//
//  ShazamViewModel.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//
import Foundation
import AVKit
import ShazamKit

func getPreferredLanguage(locale:Locale)->String {
    let langCode = String(locale.identifier.dropLast(3))
    return langCode
}
class ShazamViewModel: NSObject, ObservableObject {
    private var locale=Locale.current
    private var session = SHSession()
    private let audioEngine = AVAudioEngine()
    var wikipediaModel = WikipediaModel()
    let wikipath = ".wikipedia.org/wiki/"
    private var showArtistCantOpen = false
    private var showTitleCantOpen = false
    private var wikiUrl =  "https://en.wikipedia.org/wiki/"
    private var wikiUrlSearch = "https://en.wikipedia.org/"
@Published var viewState: ViewState = .initial
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func showInfo() {
        self.viewState = .infoAlert
    }
    
    func startListening() {
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error as NSError {
            debugPrint("ERROR:", error)
        }
        
        switch audioSession.recordPermission {
        case .undetermined:
            requestRecordPermission(audioSession: audioSession)
        case .denied:
            viewState = .recordPermissionSettingsAlert
        case .granted:
            DispatchQueue.global(qos: .background).async {
                self.proceedWithRecording()
            }
        @unknown default:
            requestRecordPermission(audioSession: audioSession)
        }
    }
    
    func stopListening() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch let error as NSError {
            debugPrint("ERROR:", error)
        }
        stopRecording()
    }
    
    private func requestRecordPermission(audioSession: AVAudioSession) {
        audioSession.requestRecordPermission { [weak self] status in
            DispatchQueue.main.async {
                if status {
                    DispatchQueue.global(qos: .background).async {
                        self?.proceedWithRecording()
                    }
                } else {
                    debugPrint("Permission denied")
                }
            }
        }
    }
    
    private func proceedWithRecording() {
        DispatchQueue.main.async {
            self.viewState = .recordingInProgress
        }
        
        if audioEngine.isRunning {
            stopRecording()
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)
        
        inputNode.removeTap(onBus: .zero)
        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            debugPrint("Current Recording at: \(time)")
            self?.session.matchStreamingBuffer(buffer, at: time)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func stopRecording() {
        self.viewState = .initial
        audioEngine.stop()
    }
    
    
    func populateFromMediaPlayer(song:Song) {
        self.wikiUrl =   "https://" + getPreferredLanguage(locale: self.locale) + self.wikipath
        self.wikiUrlSearch = "https://" + getPreferredLanguage(locale: self.locale) + self.wikipath
        self.wikipediaModel.wikiUrl = self.wikiUrl
        self.wikipediaModel.wikiUrlSearch = self.wikiUrlSearch
        debugPrint("running populateFromMediaPlayer")
        debugPrint("song.album in populateFromMediaPlayer", song.album)
       self.wikipediaModel.populateCurrPlaying( title: song.title, artist: song.artist, album: song.album )
        debugPrint("back from populateFromMediaPlayer")
        self.viewState = .result(song: song, wikipediaModel: self.wikipediaModel)
        
    }
}
extension ShazamViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let firstMatch = match.mediaItems.first else {
            return
        }
        stopRecording()

        let song = Song(
            title: firstMatch.title ?? "",
            artist: firstMatch.artist ?? "",
            genres: firstMatch.genres,
            artworkUrl: firstMatch.artworkURL,
            appleMusicUrl: firstMatch.appleMusicURL,
            mpMediaItemArtwork: nil,
            album: ""
        )
        DispatchQueue.main.async {
            self.wikiUrl =   "https://" + getPreferredLanguage(locale: self.locale) + self.wikipath
            self.wikiUrlSearch = "https://" + getPreferredLanguage(locale: self.locale) + self.wikipath
            self.wikipediaModel.wikiUrl = self.wikiUrl
            self.wikipediaModel.wikiUrlSearch = self.wikiUrlSearch
            debugPrint("running populateCurrPlaying")
            self.wikipediaModel.populateCurrPlaying( title: song.title, artist: song.artist, album: song.album)
            
            debugPrint("back from populateCurrPlaying")
            debugPrint("FROM SHAZAM appleMusicUrl:", song.appleMusicUrl ?? "can't print appleMusicURL")
            debugPrint("FORM SHAZAM song.album", song.album)
          
            self.viewState = .result(song: song, wikipediaModel: self.wikipediaModel)
    
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        debugPrint(error?.localizedDescription ?? "")
        stopRecording()
        DispatchQueue.main.async {
            self.viewState = .noResult
        }
    }
}

extension ShazamViewModel {
    enum ViewState {
        case initial
        case recordingInProgress
        case infoAlert
        case recordPermissionSettingsAlert
        case noResult
        case result(song: Song, wikipediaModel:WikipediaModel)
    }
}
