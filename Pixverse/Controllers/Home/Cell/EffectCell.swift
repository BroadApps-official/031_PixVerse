import AVFoundation
import UIKit

final class EffectCell: UICollectionViewCell {
    static let identifier = "EffectCell"

    private var template: Template?

    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var durationLabel = UILabel()

    private let playImageView = UIImageView()
    let blurEffect = UIBlurEffect(style: .light)
    private let blurEffectView: UIVisualEffectView

    private var isVideoPlaying = false

    var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }

    override init(frame: CGRect) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
        contentView.backgroundColor = .white.withAlphaComponent(0.05)
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        videoView.addGestureRecognizer(tapGesture)
        videoView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        durationLabel.do { make in
            make.font = UIFont.CustomFont.subheadlineRegular
            make.textAlignment = .center
            make.textColor = .white
        }

        blurEffectView.do { make in
            make.layer.cornerRadius = 38
            make.layer.masksToBounds = true
            make.isHidden = true
            make.isUserInteractionEnabled = false
        }

        playImageView.do { make in
            make.image = UIImage(named: "main_play_icon")
            make.tintColor = .white
            make.isHidden = true
            make.isUserInteractionEnabled = false
        }

        contentView.addSubview(videoView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(blurEffectView)
        contentView.addSubview(playImageView)

        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(videoView.snp.leading).offset(16)
            make.bottom.equalTo(videoView.snp.bottom).offset(-16)
        }

        playImageView.snp.makeConstraints { make in
            make.center.equalTo(videoView.snp.center)
            make.size.equalTo(76)
        }

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(playImageView.snp.edges)
        }
    }

    func configure(with template: Template) {
        self.template = template

        if !isVideoPlaying {
            loadVideo(for: template)
        }
    }

    private func loadVideo(for template: Template) {
        CacheManager.shared.loadVideo(for: template) { [weak self] result in
            switch result {
            case let .success(videoURL):
                self?.playVideo(from: videoURL)
            case let .failure(error):
                print("Error loading video for template \(template.id): \(error.localizedDescription)")
            }
        }
    }

    private func playVideo(from url: URL) {
        guard !isVideoPlaying else {
            return
        }

        if player != nil {
            print("Player already exists.")
        } else {
            player = AVPlayer(url: url)
            player?.volume = 0.0
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill

            DispatchQueue.main.async { [weak self] in
                self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
                if self?.playerLayer?.superlayer == nil {
                    self?.videoView.layer.addSublayer(self?.playerLayer ?? CALayer())
                }
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            DispatchQueue.main.async { [weak self] in
                var error: NSError?
                let status = self?.player?.currentItem?.asset.statusOfValue(forKey: "playable", error: &error)

                if status == .loaded {
                    if let duration = self?.player?.currentItem?.asset.duration {
                        let durationInSeconds = Int(round(CMTimeGetSeconds(duration)))
                        self?.durationLabel.text = "\(L.duration): \(durationInSeconds)s"
                    }
                    self?.attemptPlayVideo()
                } else {
                    print("Asset is not playable: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    private func attemptPlayVideo() {
        if player?.timeControlStatus == .paused {
            player?.playImmediately(atRate: 1.0)
        } else {
            print("Player is already playing.")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.player?.timeControlStatus == .playing {
                self?.isVideoPlaying = true
            } else {
                print("Player did not start playing. Current time control status: \(self?.player?.timeControlStatus.rawValue ?? -1)")
            }
        }
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    func startPlayingVideo() {
        guard let player = player else { return }
        player.seek(to: .zero)
        player.play()
        isVideoPlaying = true
        blurEffectView.isHidden = true
        playImageView.isHidden = true
    }

    func resetVideo() {
        player?.pause()
        player?.seek(to: .zero)
        isVideoPlaying = false
        blurEffectView.isHidden = true
        playImageView.isHidden = true
    }

    @objc private func handleTap() {
        guard let player = player else { return }

        if player.timeControlStatus == .playing {
            player.pause()
            isVideoPlaying = false
            blurEffectView.isHidden = false
            playImageView.isHidden = false
        } else {
            player.play()
            isVideoPlaying = true
            blurEffectView.isHidden = true
            playImageView.isHidden = true
        }
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
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isVideoPlaying = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
}
