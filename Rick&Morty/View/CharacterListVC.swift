//
//  ViewController.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 10/6/23.
//

import UIKit

class CharacterListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
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
        btn.layer.zPosition = 1
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
    var characters: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        configureTable()
        configureNavigationBar()
        loadCharacters()
        visualEffectView.frame = view.bounds
        setupCharacterDetailView()
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
        
        // Configurar el UIButon
        reloadButton.addTarget(self, action: #selector(highlightButton), for: .touchDown)
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let buttonX = (view.bounds.width - buttonWidth) / 2
        let buttonY = (view.bounds.height - buttonHeight) / 2
        reloadButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        let characterWidth: CGFloat = view.bounds.width * 0.75
        let characterHeight: CGFloat = view.bounds.height * 0.8
        let characterX = (view.bounds.width - characterWidth) / 2
        let characterY = (view.bounds.height - characterHeight) / 2
        characterDetailView.frame = CGRect(x: characterX, y: characterY + (navigationController?.navigationBar.frame.height ?? 40), width: characterWidth, height: characterHeight)
        
        
        invisibleButton.addTarget(self, action: #selector(handleTap), for: .touchDown)
        invisibleButton.frame = view.bounds
        
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.90)
        view.addSubview(overlayView)
        
        //visualEffectView.isUserInteractionEnabled = true
        view.addSubview(visualEffectView)
        
        print("ey")
        
        // Agregarlas a la vista principal
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(reloadButton)
        view.addSubview(invisibleButton)
        view.addSubview(characterDetailView)
    }
    
    private func loadCharacters() {

        Service.shared.fetchAllFromApiToCoredata { result in
            switch result {
            case .success(let characters):
                // Manejar los personajes obtenidos correctamente
                self.characters = characters
                DispatchQueue.main.async { [self] in
                    self.tableView.reloadData()
                    UIView.animate(withDuration: 1, animations: {
                        self.imageView.alpha = 0.0
                        self.tableView.alpha = 1.0
                    }) { _ in
                        self.imageView.isHidden = true
                    }
                }
                print("All characters: \(characters.count)")
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    UIView.animate(withDuration: 1, animations: {
                        self.imageView.alpha = 0.0
                        self.reloadButton.alpha = 1.0
                    }) { _ in
                        self.imageView.isHidden = true
                        self.reloadButton.isHidden = false
                        
                    }
                }
                // Manejar el error en la obtención de los personajes
                print("Error: \(error)")
            }
        }
        
    }
    
    private func configureNavigationBar() {
        // Crear una UILabel con el título
        let titleLabel = UILabel()
        titleLabel.text = "Rick & Morty"
        titleLabel.textColor = UIColor(red: 0.38, green: 0.81, blue: 0.29, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Retro Gaming", size: 22.0)
        titleLabel.sizeToFit()
        
        // Asignar la UILabel como la vista de título del controlador de navegación
        navigationItem.titleView = titleLabel
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(red: 0.0, green: 0.02, blue: 0.02, alpha: 1.0)
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func configureTable() {
        // Crear la UITableView
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.alpha = 0.0
        tableView.backgroundColor = UIColor.clear//UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(CharacterCell.nib(), forCellReuseIdentifier: CharacterCell.identifier)
    }

    private func setupCharacterDetailView() {
            characterDetailView = CharacterDetailView(frame: CGRect(x: 0, y: 0, width: 400, height: 850))
            characterDetailView.alpha = 0
            characterDetailView.layer.zPosition = 0
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        cell.layer.zPosition = 0
            
        // Configurar la celda con los datos correspondientes
        cell.configureWithData(name: characters[indexPath.row].name, image: characters[indexPath.row].imageData ?? Data(), state: characters[indexPath.row].status, specie: characters[indexPath.row].species)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CharacterCell else {
            return
        }
        
        cell.generalView.backgroundColor = UIColor(red: 0.62, green: 1.0, blue: 0.54, alpha: 1.0)
        
        let name = characters[indexPath.row].name
        let gender = characters[indexPath.row].gender
        let species = characters[indexPath.row].species
        let status = characters[indexPath.row].status
        let type = characters[indexPath.row].type
        let origin = characters[indexPath.row].origin.name
        let location = characters[indexPath.row].location.name
        let debut = characters[indexPath.row].episode[0]
        let imageData = characters[indexPath.row].imageData ?? Data()
        
        self.characterDetailView.setParameters(name: name, gender: gender, species: species, status: status, type: type, origin: origin, location: location, debut: debut, imagen: imageData)
        
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
    
    @objc func highlightButton() {
        reloadButton.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 0.7)
    }
}

