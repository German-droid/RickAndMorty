//
//  ViewController.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 10/6/23.
//

import UIKit
import CoreData

class CharacterListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView: UITableView!
    let searchController = UISearchController()
    let imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = Utils.shared.loadAnimatedGIF(named: "loadingGif", duration: 5)
        imageView.alpha = CGFloat(1)
        imageView.layer.zPosition = 1
        
        return imageView
    }()
    var characterDetailView: CharacterDetailView!
    let invisibleButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.layer.zPosition = 2
        btn.alpha = 0.0
        return btn
    }()
    let reloadButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.alpha = 0.0
        btn.layer.zPosition = 2
        btn.setTitle("Reintentar", for: .normal)
        btn.setTitleColor(UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0), for: .normal)
        btn.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 1.0)
        btn.layer.cornerRadius = 10.0
        return btn
    }()
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        view.layer.zPosition = 0
        return view
    }()
    var characters: [CoreCharacter] = []
    var filteredCharacters: [CoreCharacter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        visualEffectView.frame = view.bounds
        setupTable()
        setupNavigationBar()
        checkForData()
        setupCharacterDetailView()
        setupSearchController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configurar la UIImageView
        let imageViewWidthRatio: CGFloat = 0.7
        let imageViewHeightRatio: CGFloat = 0.35
        let imageViewWidth = view.bounds.width * imageViewWidthRatio
        let imageViewHeight = view.bounds.height * imageViewHeightRatio
        let x = (view.bounds.width - imageViewWidth) / 2
        let y = (view.bounds.height - imageViewHeight) / 2
        let imageViewFrame = CGRect(x: x, y: y, width: imageViewWidth, height: imageViewHeight)
        imageView.frame = imageViewFrame
        
        // Configurar la UITableView
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configurar el UIButon de reload
        reloadButton.addTarget(self, action: #selector(reloadCharacters), for: .touchDown)
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let buttonX = (view.bounds.width - buttonWidth) / 2
        let buttonY = (view.bounds.height - buttonHeight) / 2
        reloadButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        // Configurar el CharacterDetailView
        let characterWidth: CGFloat = view.bounds.width * 0.75
        let characterHeight: CGFloat = view.bounds.height * 0.8
        let characterX = (view.bounds.width - characterWidth) / 2
        let characterY = (view.bounds.height - characterHeight) / 2
        characterDetailView.frame = CGRect(x: characterX, y: characterY + (navigationController?.navigationBar.frame.height ?? 40), width: characterWidth, height: characterHeight)
        
        // Configurar el UIButon invisible
        invisibleButton.addTarget(self, action: #selector(handleTap), for: .touchDown)
        invisibleButton.frame = view.bounds
        
        // Configurar la imagen de background
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        
        // Crear una capa casi opaca con la que oscurecer el fondo
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.90)
        
        // Añadir todas las views
        view.addSubview(overlayView)
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(reloadButton)
        view.addSubview(invisibleButton)
        view.addSubview(characterDetailView)
    }
    
    // MARK: - Views' configurations
    
    private func checkForData() {
        
        if Service.shared.checkIfItemExist() {
            Service.shared.retrieveFromCoreData { result in
                switch result {
                case .success(let allSavedCharacters):
                    self.characters = allSavedCharacters
                    
                    DispatchQueue.main.async { [self] in
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 1, animations: {
                            self.imageView.alpha = 0.0
                            self.tableView.alpha = 1.0
                        }) { _ in
                            self.imageView.isHidden = true
                            self.searchController.searchBar.isHidden = false
                            self.navigationItem.rightBarButtonItem?.isHidden = false
                        }
                    }
                    
                case .failure(_):
                    DispatchQueue.main.async { [self] in
                        UIView.animate(withDuration: 1, animations: {
                            self.imageView.alpha = 0.0
                            self.reloadButton.alpha = 1.0
                        }) { _ in
                            self.imageView.isHidden = true
                            self.reloadButton.isHidden = false
                            
                        }
                    }
                }
            }
        } else {
            loadCharacters()
        }
        
    }
    
    private func loadCharacters() {

        Service.shared.fetchAllFromApiToCoreData { result in
            switch result {
            case .success:
                // Successfully saved to CoreData
                
                Service.shared.retrieveFromCoreData { result in
                    
                    switch result {
                    case .success(let allSavedCharacters):
                        
                        self.characters = allSavedCharacters
                        DispatchQueue.main.async { [self] in
                            self.tableView.reloadData()
                            UIView.animate(withDuration: 1, animations: {
                                self.imageView.alpha = 0.0
                                self.tableView.alpha = 1.0
                            }) { _ in
                                self.imageView.isHidden = true
                                self.searchController.searchBar.isHidden = false
                                self.navigationItem.rightBarButtonItem?.isHidden = false
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async { [self] in
                            UIView.animate(withDuration: 1, animations: {
                                self.imageView.alpha = 0.0
                                self.reloadButton.alpha = 1.0
                            }) { _ in
                                self.imageView.isHidden = true
                                self.reloadButton.isHidden = false
                                
                            }
                        }
                    }
                    
                }
                
            case .failure(_):
                Service.shared.deleteFromPersistent()
                DispatchQueue.main.async { [self] in
                    UIView.animate(withDuration: 1, animations: {
                        self.imageView.alpha = 0.0
                        self.reloadButton.alpha = 1.0
                    }) { _ in
                        self.imageView.isHidden = true
                        self.reloadButton.isHidden = false
                        
                    }
                }
            }
        }
        
    }
    
    private func setupNavigationBar() {
        
        let titleLabel = UILabel()
        titleLabel.text = "Rick & Morty"
        titleLabel.textColor = UIColor(red: 0.38, green: 0.81, blue: 0.29, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Retro Gaming", size: 22.0)
        titleLabel.sizeToFit()
        
        navigationItem.titleView = titleLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(manageSearchBar))
        navigationItem.rightBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(red: 0.0, green: 0.02, blue: 0.02, alpha: 1.0)
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupTable() {
        // Crear la UITableView
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.alpha = 0.0
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CharacterCell.nib(), forCellReuseIdentifier: CharacterCell.identifier)
    }

    private func setupCharacterDetailView() {
        characterDetailView = CharacterDetailView(frame: CGRect(x: 0, y: 0, width: 400, height: 850))
        characterDetailView.alpha = 0
        characterDetailView.layer.zPosition = 0
    }
    
    func setupSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
        navigationItem.searchController?.searchBar.setValue("Cancel", forKey: "cancelButtonText")
        searchController.searchBar.barTintColor = UIColor(red: 0.03, green: 0.1, blue: 0.03, alpha: 0.5)
        searchController.searchBar.tintColor = UIColor(red: 0.38, green: 0.81, blue: 0.29, alpha: 1.0)
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Type a character's name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.18, green: 0.51, blue: 0.19, alpha: 1.0)])
        UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.18, green: 0.51, blue: 0.19, alpha: 1.0)]

        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.isHidden = true
        searchController.searchBar.delegate = self
        
    }
    
    // MARK: - Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredCharacters.count : characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        let character = searchController.isActive ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        
        guard let name = character.name, let status = character.status, let species = character.species, let imageData = character.image else {
            return UITableViewCell()
        }
        cell.configureWithData(name: name, image: imageData, state: status, specie: species)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CharacterCell else {
            return
        }
        cell.generalView.backgroundColor = UIColor(red: 0.62, green: 1.0, blue: 0.54, alpha: 1.0)
        
        let character = searchController.isActive ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        
        guard let name = character.name, let gender = character.gender, let species = character.species, let status = character.status, let type = character.type, let origin = character.origin, let location = character.location, let debut = character.debut, let imageData = character.image else {
            return
        }
        self.characterDetailView.setParameters(name: name,
                                               gender: gender,
                                               species: species,
                                               status: status,
                                               type: type,
                                               origin: origin,
                                               location: location,
                                               debut: debut,
                                               imagen: imageData)
        
        UIView.animate(withDuration: 1, animations: {
            self.visualEffectView.layer.zPosition = 2
            self.visualEffectView.alpha = 1
            cell.generalView.backgroundColor = .clear
            self.invisibleButton.layer.zPosition = 3
            self.invisibleButton.isHidden = false
            self.invisibleButton.alpha = 1
            self.characterDetailView.alpha = 1
            self.characterDetailView.layer.zPosition = 4
        }) { _ in
        }
        
    }
    
    // MARK: - SearchBar methods
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        filterForSearchText(searchText: searchText)
    }
    
    func filterForSearchText(searchText: String) {
        filteredCharacters.removeAll()

        var searchTextMatch: Bool
        for character in characters {
            if searchController.searchBar.text != "" {
                guard let name = character.name else {
                    return
                }
                searchTextMatch = name.lowercased().contains(searchText.lowercased())
            } else {
                searchTextMatch = true
            }
            if searchTextMatch {
                filteredCharacters.append(character)
            }
        }
        tableView.reloadData()
    }

    // MARK: - Selectors
    
    @objc func handleTap() {
        UIView.animate(withDuration: 1, animations: {
            self.visualEffectView.alpha = 0
            self.visualEffectView.layer.zPosition = 0
            self.invisibleButton.layer.zPosition = 0
            self.invisibleButton.isHidden = true
            self.invisibleButton.alpha = 0
            self.characterDetailView.alpha = 0
            self.characterDetailView.layer.zPosition = 0
        }) { _ in
        }
    }
    
    @objc func reloadCharacters() {
        reloadButton.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 1.0)
        reloadButton.isHidden = true
        imageView.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.imageView.alpha = 1.0
        }) { _ in
            self.imageView.isHidden = false
        }
        loadCharacters()
    }
    
    @objc func manageSearchBar() {
        if navigationItem.searchController == nil {
            navigationItem.searchController = searchController
        } else {
            navigationItem.searchController = nil
        }
    }
}

