import ApphudSDK
import AVFoundation
import MobileCoreServices
import SnapKit
import StoreKit
import UIKit
import UniformTypeIdentifiers

final class HomeViewController: UIViewController {
    private let purchaseManager = SubscriptionManager()

    private var groupedTemplates: [(category: String, templates: [Template])] = []
    private var templates: [Template] = []
    private var selectedTemplate: Template?
    private var selectedImage: UIImage?
    private var selectedImagePath: String?
    private var generatedURL: String?
    private let selectButton = GeneralButton()
    private var activeIndexPath: IndexPath?

    var activeGenerationCount = 0
    let maxGenerationCount = 2

    private var generationCount: Int {
        get { UserDefaults.standard.integer(forKey: "generationCount") }
        set { UserDefaults.standard.set(newValue, forKey: "generationCount") }
    }

    private var isFirstGeneration: Bool = false
    private var experimentV = String()

    private lazy var actionProgress: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewLayout = experimentV == "v2" ? createCompositionalLayout() : UICollectionViewFlowLayout()

        if let flowLayout = layout as? UICollectionViewFlowLayout, experimentV == "v1" {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(EffectCell.self, forCellWithReuseIdentifier: EffectCell.identifier)
        collectionView.register(EffectV2Cell.self, forCellWithReuseIdentifier: EffectV2Cell.identifier)
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        if experimentV == "v1" {
            collectionView.isPagingEnabled = true
        }
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(174), heightDimension: .absolute(228))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(174 * 3), heightDimension: .absolute(228))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(4)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(56))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = 8
            return section
        }
    }

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

        NotificationCenter.default.addObserver(self, selector: #selector(updateTemplates(_:)), name: .templatesUpdated, object: nil)

        navigationItem.title = L.home
        if !purchaseManager.hasUnlockedPro {
            setupRightBarButton()
        }
        view.backgroundColor = UIColor.bgPrimary

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            experimentV = appDelegate.experimentV
        }

        drawSelf()

        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self

        let userDefaultsKey = "recentVideoGenerationIds"
        if let recentGenerationIds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            if let lastGenerationId = recentGenerationIds.last {
                fetchSingleStatus(for: lastGenerationId)
            }
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            templates = appDelegate.cachedTemplates
            print("templatestemplates: \(templates)")
        }

        selectedTemplate = templates.first
        if experimentV == "v1" {
            navigationItem.title = templates.first?.effect
        } else {
            navigationItem.title = L.home
        }
        toggleActionProgress()

        if experimentV == "v2" {
            groupTemplatesByCategory()
            collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        }
    }

    private func groupTemplatesByCategory() {
        let groupedDict = Dictionary(grouping: templates, by: { $0.categoryTitleEn })
        groupedTemplates = groupedDict.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .templatesUpdated, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if experimentV == "v1" {
            let topSafeArea = view.safeAreaInsets.top
            collectionView.contentInset = UIEdgeInsets(top: -topSafeArea, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc private func updateTemplates(_ notification: Notification) {
        guard let updatedTemplates = notification.object as? [Template] else {
            print("Error: updatedTemplates is not of type [Template].")
            return
        }

        if experimentV == "v2" {
            var groupedNewTemplates: [(category: String, templates: [Template])] = []
            for template in updatedTemplates {
                if let index = groupedNewTemplates.firstIndex(where: { $0.category == template.categoryTitleEn }) {
                    if let existingTemplate = groupedNewTemplates[index].templates.first(where: { $0.id == template.id }) {
                        if existingTemplate.preview != template.preview {
                            groupedNewTemplates[index].templates[index].preview = template.preview
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            return
                        }
                    } else {
                        groupedNewTemplates[index].templates.append(template)
                    }
                } else {
                    groupedNewTemplates.append((category: template.categoryTitleEn, templates: [template]))
                }
            }

            groupedTemplates = groupedNewTemplates
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            var newTemplates: [Template] = []

            for template in updatedTemplates {
                if let existingIndex = templates.firstIndex(where: { $0.id == template.id }) {
                    let existingTemplate = templates[existingIndex]

                    if existingTemplate.preview != template.preview {
                        templates[existingIndex] = template
                        DispatchQueue.main.async {
                            self.collectionView.reloadItems(at: [IndexPath(row: existingIndex, section: 0)])
                        }
                    }
                } else {
                    newTemplates.append(template)
                }
            }

            if !newTemplates.isEmpty {
                templates.append(contentsOf: newTemplates)
                let indexPaths = newTemplates.map { template in
                    IndexPath(row: self.templates.firstIndex(where: { $0.id == template.id })!, section: 0)
                }
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: indexPaths)
                }
            } else {
                print("No new templates to add.")
            }
        }

        toggleActionProgress()
    }

    private func drawSelf() {
        selectButton.do { make in
            make.selectMode()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelectButton))
            make.addGestureRecognizer(tapGesture)
            if experimentV == "v2" {
                make.isHidden = true
            } else {
                make.isHidden = false
            }
        }

        if experimentV == "v2" {
            view.addSubviews(collectionView, actionProgress)
        } else {
            view.addSubviews(collectionView, actionProgress, selectButton)
        }

        if experimentV == "v1" {
            collectionView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        } else if experimentV == "v2" {
            collectionView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            }
        }

        if experimentV == "v1" {
            selectButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35)
                make.trailing.equalToSuperview().inset(16)
                make.height.equalTo(42)
                make.width.equalTo(175)
            }
        }

        actionProgress.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func selectButtonTapped() {
        showImagePickerController(sourceType: .photoLibrary)
    }

    @objc private func photoButtonTapped() {
        showImagePickerController(sourceType: .camera)
    }

    @objc private func startGeneration() {
        if activeGenerationCount >= maxGenerationCount {
            let alert = UIAlertController(
                title: L.generationLimitReached,
                message: L.generationLimitReachedMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.overrideUserInterfaceStyle = .dark
            present(alert, animated: true, completion: nil)
            return
        }

        if generationCount == 0 {
            isFirstGeneration = true
            generationCount += 1
        } else {
            isFirstGeneration = false
            generationCount += 1
        }

        let generationVC = GenerationTimeViewController()
        let navigationController = UINavigationController(rootViewController: generationVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)

        guard let selectedTemplateId = selectedTemplate?.id else {
            print("Template not selected")
            return
        }

        guard let selectedImage = selectedImage else {
            print("No image selected")
            return
        }

        guard let selectedTemplateEffect = selectedTemplate?.effect else {
            print("Template effect not found")
            return
        }

        guard let selectedImagePath = selectedImagePath else {
            print("Image path is not available")
            return
        }

        activeGenerationCount += 1

        let tempURL = saveImageToTemporaryDirectory(selectedImage)
        let userId = Apphud.userID()

        NetworkService.shared.generateEffect(
            templateId: "\(selectedTemplateId)",
            imageFilePath: tempURL?.path,
            userId: userId,
            appId: Bundle.main.bundleIdentifier ?? "com.test.test"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    let generationId = data.data.generationId
                    self.saveGenerationIdToUserDefaults(generationId)
                    self.pollGenerationStatus(generationId: generationId, selectedTemplateEffect: selectedTemplateEffect, imagePath: selectedImagePath)
                case let .failure(error):
                    print("Generation failed: \(error)")
                    if self.isFirstGeneration {
                        self.generationCount -= 1
                    }
                    navigationController.dismiss(animated: true, completion: nil)
                    self.generationIdError()
                }
            }
        }
    }

    private func saveGenerationIdToUserDefaults(_ generationId: String) {
        let userDefaultsKey = "recentVideoGenerationIds"
        var recentGenerationIds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []

        recentGenerationIds.append(generationId)
        if recentGenerationIds.count > 2 {
            recentGenerationIds.removeFirst()
        }

        UserDefaults.standard.set(recentGenerationIds, forKey: userDefaultsKey)
    }

    private func fetchSingleStatus(for generationId: String) {
        NetworkService.shared.fetchEffectGenerationStatus(generationId: generationId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    if data.status == "error" {
                        self.checkGenerationStatus()
                    } else if data.status == "finished" {
                        let allVideoModels = MemoryManager.shared.loadAllVideoModels()
                        if let matchingVideoModelIndex = allVideoModels.firstIndex(where: { $0.generationId == generationId }) {
                            let matchingVideoModel = allVideoModels[matchingVideoModelIndex]

                            if matchingVideoModel.isFinished == false {
                                self.pollGenerationStatus(
                                    generationId: matchingVideoModel.generationId,
                                    selectedTemplateEffect: matchingVideoModel.name,
                                    imagePath: matchingVideoModel.imagePath ?? ""
                                )
                            }
                        }
                    } else {
                        let allVideoModels = MemoryManager.shared.loadAllVideoModels()

                        if let matchingVideoModel = allVideoModels.first(where: { $0.generationId == generationId }) {
                            self.pollGenerationStatus(
                                generationId: matchingVideoModel.generationId,
                                selectedTemplateEffect: matchingVideoModel.name,
                                imagePath: matchingVideoModel.imagePath ?? ""
                            )
                        }
                    }
                case let .failure(error):
                    print("Failed to fetch status: \(error.localizedDescription)")
                }
            }
        }
    }

    func pollGenerationStatus(generationId: String, selectedTemplateEffect: String, imagePath: String) {
        var permanentImagePath: String?

        if let image = UIImage(named: imagePath) {
            if let savedImageURL = saveImageToPermanentDirectory(image) {
                permanentImagePath = savedImageURL.path
            }
        }

        var timer: Timer?
        let videoId = UUID()
        let creationDate = Date()

        var finalImagePath = permanentImagePath ?? imagePath
        var existingModel: GeneratedVideoModel?

        let allVideoModels = MemoryManager.shared.loadAllVideoModels()
        if let model = allVideoModels.first(where: { $0.generationId == generationId }) {
            existingModel = model
            finalImagePath = model.imagePath ?? finalImagePath
        }

        let initialVideo = existingModel ?? GeneratedVideoModel(
            id: videoId,
            name: selectedTemplateEffect,
            video: nil,
            imagePath: finalImagePath,
            isFinished: false,
            createdAt: creationDate,
            generationId: generationId
        )

        MemoryManager.shared.saveOrUpdateVideoModel(initialVideo) { success in
            if success {
                print("Initial MyVideoModel cached successfully.")
            } else {
                print("Failed to cache initial MyVideoModel.")
            }
        }

        func fetchStatus() {
            NetworkService.shared.fetchEffectGenerationStatus(generationId: generationId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(data):

                        if data.status == "finished", let resultUrl = data.resultUrl {
                            if let existingModel = MemoryManager.shared.loadAllVideoModels().first(where: { $0.generationId == generationId }) {
                                var updatedVideo = existingModel
                                updatedVideo.video = resultUrl
                                updatedVideo.isFinished = true
                                updatedVideo.imagePath = nil
                                MemoryManager.shared.saveOrUpdateVideoModel(updatedVideo) { success in
                                    if success {
                                        print("Updated MyVideoModel cached successfully.")
                                    } else {
                                        print("Failed to cache updated MyVideoModel.")
                                    }
                                }
                            }

                            let updatedVideo = GeneratedVideoModel(
                                id: videoId,
                                name: selectedTemplateEffect,
                                video: resultUrl,
                                imagePath: nil,
                                isFinished: true,
                                createdAt: creationDate,
                                generationId: generationId
                            )

                            let generationCountToPass = self.generationCount
                            let resultVC = ResultViewController(model: updatedVideo, generationCount: generationCountToPass)
                            resultVC.delegate = self
                            let navigationController = UINavigationController(rootViewController: resultVC)
                            navigationController.modalPresentationStyle = .fullScreen
                            self.present(navigationController, animated: true, completion: nil)

                            self.activeGenerationCount -= 1
                            timer?.invalidate()
                        } else if data.status == "error" {
                            if self.isFirstGeneration {
                                self.generationCount -= 1
                            }
                            self.generationIdError()
                            timer?.invalidate()
                        } else {
                            print("Status: \(data.status), Progress: \(data.progress ?? 0)%")
                        }
                    case let .failure(error):
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case let .serverError(statusCode) where statusCode == 500:
                                print("Server error: 500. Retrying...")
                            default:
                                print("Error while polling: \(networkError)")
                                self.generationErrorAlert(generationId: generationId,
                                                          selectedTemplateEffect: selectedTemplateEffect,
                                                          imagePath: imagePath)
                                timer?.invalidate()
                            }
                        } else {
                            print("Unknown error: \(error)")
                            self.generationErrorAlert(
                                generationId: generationId,
                                selectedTemplateEffect: selectedTemplateEffect,
                                imagePath: imagePath
                            )
                            timer?.invalidate()
                        }

                        self.activeGenerationCount -= 1

                        if self.isFirstGeneration {
                            self.generationCount -= 1
                        }
                    }
                }
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            fetchStatus()
        }
    }

    private func generationErrorAlert(generationId: String, selectedTemplateEffect: String, imagePath: String) {
        let alert = UIAlertController(title: L.videoGenerationError,
                                      message: L.errorVideoGalleryMessage,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
        let tryAgainAction = UIAlertAction(title: L.tryAgain, style: .default) { _ in
            self.pollGenerationStatus(
                generationId: generationId,
                selectedTemplateEffect: selectedTemplateEffect,
                imagePath: imagePath
            )
        }

        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    private func checkGenerationStatus() {
        let alert = UIAlertController(
            title: L.previousGeneration,
            message: L.previousGenerationMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    private func generationIdError() {
        activeGenerationCount -= 1
        let alert = UIAlertController(
            title: L.videoGenerationError,
            message: L.tryDifferentPhoto,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true, completion: nil)
    }

    private func cleanUnfinishedVideos() {
        let allModels = MemoryManager.shared.loadAllVideoModels()
        let unfinishedModels = allModels.filter { $0.isFinished == false }

        for model in unfinishedModels {
            MemoryManager.shared.deleteVideoModel(withId: model.id)
        }
    }

    private func saveImageToTemporaryDirectory(_ image: UIImage) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: fileURL)
                return fileURL
            } else {
                print("Failed to convert image to JPEG")
            }
        } catch {
            print("Failed to save image to temporary directory: \(error)")
        }

        return nil
    }

    private func saveImageToPermanentDirectory(_ image: UIImage) -> URL? {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"

        let fileURL = cachesDirectory.appendingPathComponent(fileName)

        do {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: fileURL)
                return fileURL
            } else {
                print("Failed to convert image to JPEG")
            }
        } catch {
            print("Failed to save image to caches directory: \(error)")
        }

        return nil
    }

    private func toggleActionProgress() {
        if templates.isEmpty {
            actionProgress.startAnimating()
            selectButton.isHidden = true
        } else {
            actionProgress.stopAnimating()
            selectButton.isHidden = false
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

    @objc private func openSubscription() {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false, isExitShown: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }

    @objc private func openGeneration() {
        let generationVC = GenerationTimeViewController()
        let navigationController = UINavigationController(rootViewController: generationVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func didTapSelectButton() {
        if purchaseManager.hasUnlockedPro {
            Task {
                await checkUserTokens()
            }
        } else {
            openSubscription()
        }
    }

    private func checkUserTokens() async {
        let userId = Apphud.userID()
        let bundle = Bundle.main.bundleIdentifier ?? "com.test.test"

        do {
            let updatedTokens = try await NetworkService.shared.getUserTokens(
                userId: userId,
                bundleId: bundle
            )

            if updatedTokens < 1 {
                DispatchQueue.main.async {
                    let tokensVC = TokenViewController()
                    tokensVC.modalPresentationStyle = .fullScreen
                    self.present(tokensVC, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.showImageSelectionAlert()
                }
            }
        } catch {
            print("Token error: \(error.localizedDescription)")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let resizedImage = resizeImageIfNeeded(image: selectedImage, maxWidth: 1260, maxHeight: 760)
            self.selectedImage = resizedImage

            if let imageURL = info[.imageURL] as? URL {
                selectedImagePath = imageURL.path
            } else {
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

                if let imageData = resizedImage.jpegData(compressionQuality: 1.0) {
                    do {
                        try imageData.write(to: tempFileURL)
                        selectedImagePath = tempFileURL.path
                    } catch {
                        print("Failed to save camera photo to temporary directory: \(error)")
                        selectedImagePath = nil
                    }
                }
            }
        }

        picker.dismiss(animated: true) {
            if self.selectedImage != nil && self.selectedImagePath != nil {
                self.startGeneration()
            }
        }
    }

    func resizeImageIfNeeded(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let widthRatio = maxWidth / originalWidth
        let heightRatio = maxHeight / originalHeight

        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: originalWidth * scaleFactor, height: originalHeight * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if experimentV == "v2" {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectV2Cell.identifier, for: indexPath) as? EffectV2Cell else {
                return UICollectionViewCell()
            }
            let template = groupedTemplates[indexPath.section].templates[indexPath.item]
            cell.configure(with: template)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectCell.identifier, for: indexPath) as? EffectCell else {
                return UICollectionViewCell()
            }
            let template = templates[indexPath.item]
            cell.configure(with: template)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }

        let categoryTitle = groupedTemplates[indexPath.section].category
        header.configure(with: categoryTitle, sectionIndex: indexPath.section)
        header.delegate = self

        return header
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if experimentV == "v2" {
            return groupedTemplates.count
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if experimentV == "v2" {
            return groupedTemplates[section].templates.count
        } else {
            return templates.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if experimentV == "v2" {
            for visibleIndexPath in collectionView.indexPathsForVisibleItems {
                if let cell = collectionView.cellForItem(at: visibleIndexPath) as? EffectV2Cell {
                    cell.contentView.layer.borderWidth = 0
                    cell.contentView.layer.borderColor = nil
                }
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? EffectV2Cell {
                selectedTemplate = templates[indexPath.item]
            }

            if purchaseManager.hasUnlockedPro {
                Task {
                    await checkUserTokens()
                }
            } else {
                openSubscription()
            }
        }
    }

    private func showImageSelectionAlert() {
        let alert = UIAlertController(
            title: L.selectAction,
            message: L.selectActionSublabel,
            preferredStyle: .actionSheet
        )

        alert.overrideUserInterfaceStyle = .dark

        let selectFromGalleryAction = UIAlertAction(
            title: L.selectGallery,
            style: .default
        ) { _ in
            self.selectButtonTapped()
        }

        let takePhotoAction = UIAlertAction(
            title: L.takePphoto,
            style: .default
        ) { _ in
            self.photoButtonTapped()
        }

        let cancelAction = UIAlertAction(
            title: L.cancel,
            style: .cancel
        )

        alert.addAction(selectFromGalleryAction)
        alert.addAction(takePhotoAction)
        alert.addAction(cancelAction)

        if UIDevice.isIpad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popoverController.permittedArrowDirections = []
            }
        }

        present(alert, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if experimentV == "v1" {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            return CGSize(width: 174, height: 228)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = collectionView.indexPathsForVisibleItems
            .sorted { top, bottom -> Bool in
                top.section < bottom.section || top.row < bottom.row
            }

        for indexPath in visibleCells {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EffectCell else { continue }
            let cellRect = collectionView.layoutAttributesForItem(at: indexPath)?.frame
            let isCompletelyVisible = collectionView.bounds.contains(cellRect ?? CGRect.zero)

            if isCompletelyVisible {
                let template = templates[indexPath.item]
                selectedTemplate = template
                if experimentV == "v1" {
                    navigationItem.title = template.effect
                } else {
                    navigationItem.title = L.home
                }
                cell.startPlayingVideo()
            } else {
                cell.resetVideo()
            }
        }
    }
}

// MARK: - HeaderViewDelegate
extension HomeViewController: HeaderViewDelegate {
    func didTapHeaderButton(sectionIndex: Int) {
        let selectedCategory = groupedTemplates[sectionIndex]
        let openCategoryVC = OpenCategoryViewController(models: selectedCategory.templates)
        let navigationController = UINavigationController(rootViewController: openCategoryVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - ResultViewControllerDelegate
extension HomeViewController: ResultViewControllerDelegate {
    func didTapCloseButton() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

extension Notification.Name {
    static let templatesUpdated = Notification.Name("templatesUpdated")
}
