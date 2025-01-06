import AVFoundation
import AVKit
import SnapKit
import UIKit

protocol ResultViewControllerDelegate: AnyObject {
    func didTapCloseButton()
}

final class ResultViewController: UIViewController {
    // MARK: - Properties

    private let backButton = UIButton(type: .system)
    private let menuButton = UIButton(type: .system)

    private let playButton = UIButton()
    let blurEffect = UIBlurEffect(style: .light)
    private let blurEffectView: UIVisualEffectView

    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private var generatedURL: String?
    private var model: GeneratedVideoModel
    private let isFirstGeneration: Bool
    private var aspectRatio: CGFloat = 16 / 9
    private var isPlaying = false

    private let shareButton = GeneralButton()
    weak var delegate: ResultViewControllerDelegate?

    // MARK: - Init
    init(model: GeneratedVideoModel, isFirstGeneration: Bool) {
        self.model = model
        self.isFirstGeneration = isFirstGeneration
        generatedURL = model.video
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false

        navigationItem.title = L.result

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.CustomFont.bodyEmphasized,
            .foregroundColor: UIColor.labelsPrimary
        ]

        setupBackButton()
        setupMenuButton()
        view.backgroundColor = UIColor.bgPrimary

        drawSelf()
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shareVideo))
        shareButton.addGestureRecognizer(tapGesture)
    }

    private func drawSelf() {
        shareButton.shareMode()
        blurEffectView.do { make in
            make.layer.cornerRadius = 32
            make.layer.masksToBounds = true
        }

        playButton.do { make in
            make.layer.cornerRadius = 32
            make.setImage(UIImage(named: "main_play_icon"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        }

        guard let videoURLString = generatedURL, let videoURL = URL(string: videoURLString) else {
            print("Invalid video URL")
            return
        }

        let asset = AVAsset(url: videoURL)
        let track = asset.tracks(withMediaType: .video).first

        if let naturalSize = track?.naturalSize {
            let width = naturalSize.width
            let height = naturalSize.height
            aspectRatio = width / height
        }

        player = AVPlayer(url: videoURL)

        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        if let playerVC = playerViewController {
            addChild(playerVC)
            view.addSubview(playerVC.view)
            playerVC.videoGravity = .resizeAspectFill
            playerVC.didMove(toParent: self)

            playerVC.view.snp.makeConstraints { make in
                make.centerY.equalTo(view)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(view.snp.width).multipliedBy(1 / aspectRatio)
            }
        }

        view.addSubview(blurEffectView)
        view.addSubview(playButton)
        view.addSubview(shareButton)

        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(64)
        }

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(playButton.snp.edges)
        }

        shareButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(58)
        }
    }

    private func setupBackButton() {
        backButton.do { make in
            make.setTitle(L.back, for: .normal)
            make.setTitleColor(UIColor.labelsPrimary, for: .normal)
            make.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            make.tintColor = UIColor.labelsPrimary
            make.semanticContentAttribute = .forceLeftToRight

            make.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        }

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    private func setupMenuButton() {
        menuButton.do { make in
            make.setImage(UIImage(named: "result_menu_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
            make.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        }

        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarButtonItem
    }

    @objc private func didTapCloseButton() {
        if isFirstGeneration {
            dismiss(animated: true) {
                self.delegate?.didTapCloseButton()
            }
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func didTapMenuButton() {
        menuButton.overrideUserInterfaceStyle = .dark
        let shareAction = UIAction(title: L.saveGallery, image: UIImage(systemName: "arrow.down.to.line")) { _ in
            self.saveButtonTapped()
        }

        let saveToFileAction = UIAction(title: L.save, image: UIImage(systemName: "folder.badge.plus")) { _ in
            self.saveToFiles()
        }

        let deleteAction = UIAction(title: L.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteVideo()
        }

        let menu = UIMenu(title: "", children: [shareAction, saveToFileAction, deleteAction])
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }

    @objc private func didTapPlayButton() {
        if isPlaying {
            player?.pause()
            playButton.setImage(UIImage(named: "main_play_icon"), for: .normal)
        } else {
            player?.play()
            playButton.setImage(UIImage(named: "main_pause_icon"), for: .normal)
        }
        isPlaying.toggle()
    }

    @objc private func didFinishPlaying() {
        player?.seek(to: .zero)

        playButton.setImage(UIImage(named: "main_play_icon"), for: .normal)
        isPlaying = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func saveButtonTapped() {
        guard let videoURLString = generatedURL, let videoURL = URL(string: videoURLString) else {
            videoGalleryErrorAlert()
            return
        }

        VideoSaver.downloadVideo(from: videoURL) { localURL in
            guard let localURL = localURL else {
                DispatchQueue.main.async {
                    self.videoGalleryErrorAlert()
                }
                return
            }

            let mediaSaver = VideoSaver()
            mediaSaver.saveVideoToGallery(videoURL: localURL) { success in
                DispatchQueue.main.async {
                    if success {
                        self.videoGallerySuccessAlert()
                    } else {
                        self.videoGalleryErrorAlert()
                    }
                }
            }
        }
    }

    @objc private func shareVideo() {
        guard let videoURLString = generatedURL, let videoURL = URL(string: videoURLString) else {
            print("Invalid video URL")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    private func saveToFiles() {
        guard let videoURLString = generatedURL, let videoURL = URL(string: videoURLString) else {
            videoFilesErrorAlert()
            return
        }

        VideoSaver.downloadVideo(from: videoURL) { localURL in
            guard let localURL = localURL else {
                DispatchQueue.main.async {
                    self.videoFilesErrorAlert()
                }
                return
            }

            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [localURL])
                documentPicker.delegate = self
                documentPicker.overrideUserInterfaceStyle = .dark
                self.present(documentPicker, animated: true)
            }
        }
    }

    @objc private func deleteVideo() {
        let alert = UIAlertController(title: L.deleteVideo,
                                      message: L.deleteVideoMessage,
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: L.delete, style: .destructive) { _ in
            CacheManager.shared.deleteVideoModel(withId: self.model.id)
            self.dismiss(animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: L.cancel, style: .cancel) { _ in
            print("Video deletion was cancelled.")
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension ResultViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        videoFilesSuccessAlert()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        videoFilesErrorAlert()
    }
}

// MARK: - Alerts
extension ResultViewController {
    private func videoGallerySuccessAlert() {
        let alert = UIAlertController(title: L.videoSavedGallery,
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    private func videoGalleryErrorAlert() {
        let alert = UIAlertController(title: L.errorVideoGallery,
                                      message: L.errorVideoGalleryMessage,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
        let tryAgainAction = UIAlertAction(title: L.tryAgain, style: .default) { _ in
            self.saveButtonTapped()
        }

        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    private func videoFilesSuccessAlert() {
        let alert = UIAlertController(title: L.videoSavedFiles,
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    private func videoFilesErrorAlert() {
        let alert = UIAlertController(title: L.errorVideoFiles,
                                      message: L.errorVideoGalleryMessage,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
        let tryAgainAction = UIAlertAction(title: L.tryAgain, style: .default) { _ in
            self.saveToFiles()
        }

        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}
