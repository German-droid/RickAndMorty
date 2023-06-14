//
//  CharacterDetailView.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 12/6/23.
//

import UIKit

class CharacterDetailView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var genealView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var portalBackgroundImage: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterGender: UILabel!
    @IBOutlet weak var characterSpecies: UILabel!
    @IBOutlet weak var characterStatus: UILabel!
    @IBOutlet weak var characterType: UILabel!
    @IBOutlet weak var characterOrigin: UILabel!
    @IBOutlet weak var characterLocation: UILabel!
    @IBOutlet weak var characterFirstAppearance: UILabel!
    var characterImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    private func setupFromNib() {
        Bundle.main.loadNibNamed("CharacterDetailView", owner: self, options: nil)
        addSubview(contentView)
           
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Agrega una función que se llamará después de que la vista se haya cargado completamente
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.red.cgColor
        
        DispatchQueue.main.async {
            self.updateImageViewSize()
        }
    }
    
    private func updateImageViewSize() {
        guard let image = UIImage(named: "example") else {
                // Maneja el caso en el que no se pueda cargar el asset
                return
            }

        let height = portalBackgroundImage.frame.size.height * 0.7
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
            imageView.layer.cornerRadius = imageView.bounds.width / 2
            imageView.image = image
            
            // Redondea la imagen después de que se haya establecido su marco
            imageView.layer.cornerRadius = imageView.bounds.width / 2
            imageView.layer.masksToBounds = true
            imageView.center = CGPoint(x: portalBackgroundImage.bounds.midX, y: portalBackgroundImage.bounds.midY)
        
            self.characterImage = imageView
        addSubview(characterImage)
    }
    
    func setParameters(name: String, gender: String, species: String, status: String, type: String, origin: String, location: String, debut: String, imagen: Data) {
        
        DispatchQueue.main.async { [self] in
        
        characterName.text = name
        characterGender.text = gender
        characterSpecies.text = species
        characterStatus.text = status
        characterType.text = type
        characterOrigin.text = origin
        characterLocation.text = location
        
        var episodeNumber = ""
        if let url = URL(string: debut) {
            episodeNumber = url.lastPathComponent
        }
        
        characterFirstAppearance.text = "Episode \(episodeNumber)"
        characterImage.image = UIImage(data: imagen)
        }
    }
    
    
}
