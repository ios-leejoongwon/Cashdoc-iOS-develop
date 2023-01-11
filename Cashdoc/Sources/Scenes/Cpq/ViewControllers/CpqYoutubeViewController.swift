//
//  CpqYoutubeViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import WebKit

class CpqYoutubeViewController: CashdocViewController {
    
    // MARK: - UI Components
    
    private let youtubeWebView = WKWebView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Properties
    public typealias YouTubePlayerParameters = [String: AnyObject]

    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func loadVideo(url: String) {
        view.addSubview(youtubeWebView)
        layout()
//        let url = "https://www.youtube.com/embed/8mP959p5OQM?rel=0&controls=1&playsinline=1&enablejsapi=1&widgetid=1"
        if let makeURL = URL(string: url) {
            youtubeWebView.load(URLRequest(url: makeURL))
        }
    }
    
    func pause() {
//        playerView.pause()
    }
}

// MARK: - Layout

extension CpqYoutubeViewController {
    
    private func layout() {
        youtubeWebView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        youtubeWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        youtubeWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        youtubeWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        youtubeWebView.heightAnchor.constraint(equalTo: youtubeWebView.widthAnchor, multiplier: 0.5).isActive = true
    }
}
