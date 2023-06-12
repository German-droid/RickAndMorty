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
        return imageView
    }()
    let reloadButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.alpha = 0.0
        btn.setTitle("Reintentar", for: .normal)
        btn.setTitleColor(UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0), for: .normal)
        btn.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 1.0)
        btn.layer.cornerRadius = 10.0
        return btn
    }()
    var characters: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
        configureTable()
        configureNavigationBar()
        loadCharacters()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configurar la UIImageView
        imageView.layer.zPosition = 1
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
        reloadButton.layer.zPosition = 2
        reloadButton.addTarget(self, action: #selector(highlightButton), for: .touchDown)
        reloadButton.addTarget(self, action: #selector(reloadCharacters), for: .touchUpInside)
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let buttonX = (view.bounds.width - buttonWidth) / 2
        let buttonY = (view.bounds.height - buttonHeight) / 2
        reloadButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.90)
        view.addSubview(overlayView)
        view.sendSubviewToBack(backgroundImage)
        
        // Agregarlas a la vista principal
        
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(reloadButton)
    }
    
    func loadCharacters() {

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
    
    func configureNavigationBar() {
        // Crear una UILabel con el título
        let titleLabel = UILabel()
        titleLabel.text = "Rick & Morty"
        titleLabel.textColor = UIColor.white
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
    
    func configureTable() {
        // Crear la UITableView
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.alpha = 0.0
        tableView.backgroundColor = UIColor.clear//UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(CharacterCell.nib(), forCellReuseIdentifier: CharacterCell.identifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        cell.isUserInteractionEnabled = true
            
        // Configurar la celda con los datos correspondientes
        cell.configureWithData(name: characters[indexPath.row].name, image: characters[indexPath.row].imageData ?? Data(), state: characters[indexPath.row].status, specie: characters[indexPath.row].species)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

