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
        
        // Agregarlas a la vista principal
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(reloadButton)
    }
    
    func loadCharacters() {
        
        let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        
        Service.shared.fetchAllFromApiToCoredata { result in
            switch result {
            case .success(let characters):
                // Manejar los personajes obtenidos correctamente
                self.characters = characters
                DispatchQueue.main.async { [self] in
                    defer {
                        semaphore.signal()
                    }
                    UIView.animate(withDuration: 1, animations: {
                        self.imageView.alpha = 0.0
                    }) { _ in
                        self.imageView.isHidden = true
                        
                    }
                    self.tableView.reloadData()
                    UIView.animate(withDuration: 1) {
                        self.tableView.alpha = 1.0
                    }
                }
                print("All characters: \(characters.count)")
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    defer {
                        semaphore.signal()
                    }
                    imageView.isHidden = true
                    reloadButton.isHidden = false
                }
                // Manejar el error en la obtención de los personajes
                print("Error: \(error)")
            }
            let timeout = DispatchTime.now() + .seconds(15)
                
            if semaphore.wait(timeout: timeout) == .timedOut {
                self.imageView.isHidden = true
                self.reloadButton.isHidden = false
            }
        }
        
    }
    
    func configureNavigationBar() {
        // Crear una UILabel con el título
        let titleLabel = UILabel()
        titleLabel.text = "Rick & Morty"
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Nunito-Regular", size: 25.0)
        titleLabel.sizeToFit()
        
        // Asignar la UILabel como la vista de título del controlador de navegación
        navigationItem.titleView = titleLabel
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func configureTable() {
        // Crear la UITableView
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.alpha = 0.0
            tableView.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
            tableView.delegate = self
            tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            
        // Configurar la celda con los datos correspondientes
        cell.textLabel?.text = "\(characters[indexPath.row].id) - \(characters[indexPath.row].name)"
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
        return cell
    }

    @objc func reloadCharacters() {
        reloadButton.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 1.0)
        reloadButton.isHidden = true
        imageView.isHidden = false
        loadCharacters()
    }
    
    @objc func highlightButton() {
        reloadButton.backgroundColor = UIColor(red: 0.45, green: 0.73, blue: 0.3, alpha: 0.7)
    }
}

