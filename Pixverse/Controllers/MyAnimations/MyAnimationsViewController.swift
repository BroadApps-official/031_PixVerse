import SnapKit
import UIKit

final class MyAnimationsViewController: UIViewController {
    private var videoModels: [GeneratedVideoModel] = []
    private var selectedVideoModel: GeneratedVideoModel?
    private let noVideoView = NoAnimationView()
    var currentVideoId: String?
    private let purchaseManager = SubscriptionManager()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.bgPrimary
        collectionView.register(AnimationCell.self, forCellWithReuseIdentifier: AnimationCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()

        title = L.myAnimations
        if !purchaseManager.hasUnlockedPro {
            setupRightBarButton()
        }
        view.backgroundColor = UIColor.bgPrimary

        drawself()
        loadAllVideoModels()
        noVideoView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllVideoModels()
    }

    private func drawself() {
        view.addSubviews(
            noVideoView, collectionView
        )

        noVideoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(214)
            make.height.equalTo(168)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.bottom.equalToSuperview()
        }
    }

    private func loadAllVideoModels() {
        let allVideoModels = CacheManager.shared.loadAllVideoModels()

        videoModels = allVideoModels.sorted { model1, model2 -> Bool in
            model1.createdAt > model2.createdAt
        }

        collectionView.reloadData()
        updateViewForVideoModels()
    }

    private func updateViewForVideoModels() {
        if videoModels.isEmpty {
            collectionView.isHidden = true
            noVideoView.isHidden = false
        } else {
            collectionView.isHidden = false
            noVideoView.isHidden = true
        }
    }

    private func setupRightBarButton() {
        let proButtonView = createCustomProButton()
        let proBarButtonItem = UIBarButtonItem(customView: proButtonView)
        navigationItem.rightBarButtonItems = [proBarButtonItem]
    }

    private func createCustomProButton() -> UIView {
        let customButtonView = UIView()
        customButtonView.backgroundColor = UIColor.colorsPro
        customButtonView.layer.cornerRadius = 10
        customButtonView.isUserInteractionEnabled = true

        let iconImageView = UIImageView(image: UIImage(named: "set_proButton_icon"))
        iconImageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = L.pro
        label.textColor = UIColor.labelsPrimary
        label.font = UIFont.CustomFont.calloutRegular

        let stackView = UIStackView(arrangedSubviews: [label, iconImageView])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        customButtonView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        customButtonView.snp.makeConstraints { make in
            make.height.equalTo(29)
            make.width.equalTo(70)
        }

        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(21)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customProButtonTapped(_:)))
        customButtonView.addGestureRecognizer(tapGesture)

        return customButtonView
    }

    @objc private func customProButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let buttonView = sender.view else { return }

        UIView.animate(withDuration: 0.05, animations: {
            buttonView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                buttonView.alpha = 1.0
            }
        }

        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false, isExitShown: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MyAnimationsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimationCell.identifier, for: indexPath) as? AnimationCell else {
            return UICollectionViewCell()
        }
        let video = videoModels[indexPath.item]
        cell.configure(with: video)
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.backgroundColor = UIColor.bgPrimary
        cell.addInteraction(interaction)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedVideoModel = videoModels[indexPath.item]
        guard selectedVideoModel.isFinished == true else {
            let alert = UIAlertController(
                title: L.videoNotReady,
                message: L.videoNotReadyMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.overrideUserInterfaceStyle = .dark
            present(alert, animated: true, completion: nil)
            return
        }

        let resultVC = ResultViewController(model: selectedVideoModel, generationCount: 0)
        let navigationController = UINavigationController(rootViewController: resultVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width)
        return CGSize(width: width, height: width)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension MyAnimationsViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let convertedLocation = collectionView.convert(location, from: interaction.view)

        guard let indexPath = collectionView.indexPathForItem(at: convertedLocation) else {
            print("Failed to find indexPath for location: \(location)")
            return nil
        }

        let selectedVideoModel = videoModels[indexPath.item]
        currentVideoId = selectedVideoModel.video
        self.selectedVideoModel = selectedVideoModel

        let deleteAction = UIAction(title: L.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteVideo()
        }

        var actions: [UIMenuElement] = [deleteAction]

        if let isFinished = selectedVideoModel.isFinished, isFinished {
            let shareAction = UIAction(title: L.saveGallery, image: UIImage(systemName: "arrow.down.to.line")) { _ in
                self.saveVideo()
            }

            let saveToFileAction = UIAction(title: L.saveFiles, image: UIImage(systemName: "folder.badge.plus")) { _ in
                self.saveVideoToFiles()
            }

            actions.insert(contentsOf: [shareAction, saveToFileAction], at: 0)
        }

        let menu = UIMenu(title: "", children: actions)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            menu
        })

        return nil
    }
}

// MARK: - Menu Functions
extension MyAnimationsViewController {
    private func saveVideo() {
        guard let videoURLString = currentVideoId, let videoURL = URL(string: videoURLString) else {
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

    private func saveVideoToFiles() {
        guard let videoURLString = currentVideoId, let videoURL = URL(string: videoURLString) else {
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

    private func deleteVideo() {
        let alert = UIAlertController(title: L.deleteVideo,
                                      message: L.deleteVideoMessage,
                                      preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: L.delete, style: .destructive) { _ in
            guard let videoModel = self.selectedVideoModel else { return }

            CacheManager.shared.deleteVideoModel(withId: videoModel.id)

            if let index = self.videoModels.firstIndex(where: { $0.id == videoModel.id }) {
                self.videoModels.remove(at: index)
            } else {
                print("Video model with ID \(videoModel.id) not found in videoModels array.")
            }
            self.collectionView.reloadData()
            self.updateViewForVideoModels()
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

// MARK: - Alerts
extension MyAnimationsViewController {
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
            self.saveVideo()
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
            self.saveVideoToFiles()
        }

        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension MyAnimationsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        videoFilesSuccessAlert()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        videoFilesErrorAlert()
    }
}

// MARK: - NoVideoViewDelegate, NoPhotoViewDelegate
extension MyAnimationsViewController: NoAnimationViewDelegate {
    func createButtonTapped() {
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0
        }
    }
}
