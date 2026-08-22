//
//  Song.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import Foundation
import MediaPlayer
struct Song {
    let title: String
    let artist: String
    let genres: [String]
    let artworkUrl: URL?
    let appleMusicUrl: URL?
    let mpMediaItemArtwork: MPMediaItemArtwork?
    let album: String
}
