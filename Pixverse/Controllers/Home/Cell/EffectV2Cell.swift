import AVFoundation
import UIKit

final class EffectV2Cell: UICollectionViewCell {
    static let identifier = "EffectV2Cell"

    private var template: Template?
    
    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var effectLabel = UILabel()
    private var isVideoPlaying = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        effectLabel.do { make in
            make.font = UIFont.CustomFont.subheadlineRegular
            make.textAlignment = .center
            make.textColor = .white
            make.textAlignment = .left
        }
        
        videoView.do { make in
            make.layer.cornerRadius = 10
            make.masksToBounds = true
        }
        
        contentView.addSubview(videoView)
        contentView.addSubview(effectLabel)
        
        videoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(200)
        }
        
        effectLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    func configure(with template: Template) {
        self.template = template
        effectLabel.text = template.effect
        if !isVideoPlaying {
            setupVideo(for: template)
        }
    }
    
    private func setupVideo(for template: Template) {
        MemoryManager.shared.loadVideo(for: template) { [weak self] result in
            switch result {
            case let .success(videoURL):
                self?.playVideo(from: videoURL)
            case let .failure(error):
                print("Error loading video for template \(template.id): \(error.localizedDescription)")
            }
        }
    }

    private func playVideo(from url: URL) {
        guard !isVideoPlaying else { return }

        if player == nil {
            player = AVPlayer(url: url)
        }
        
        player?.volume = 0

        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.playerLayer?.frame = self.videoView.bounds
                if self.playerLayer?.superlayer == nil {
                    self.videoView.layer.addSublayer(self.playerLayer!)
                }
            }
        }

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        if let currentItem = player?.currentItem {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(restartVideo),
                name: .AVPlayerItemDidPlayToEndTime,
                object: currentItem
            )
        }

        player?.play()
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async { [weak self] in
            self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil

        isVideoPlaying = false

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        if let playerItem = player?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
}
