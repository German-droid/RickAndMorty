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
    @IBOutlet weak var generalView: UIView!
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
        
        let maskLayer = CAShapeLayer()
                
        
        // Crear un UIBezierPath con esquinas redondeadas
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 25)) // Punto inicial
        path.addLine(to: CGPoint(x: 25, y: 0)) // Diagonal derecha arriba 25
        path.addLine(to: CGPoint(x: generalView.bounds.width-25, y: 0)) // Derecha hasta -25 del width total
        path.addLine(to: CGPoint(x: generalView.bounds.width, y: 25)) // Diagonal derecha abajo 25
        path.addLine(to: CGPoint(x: generalView.bounds.width, y: generalView.bounds.height-25)) // Hasta abajo -25
        path.addLine(to: CGPoint(x: generalView.bounds.width-25, y: generalView.bounds.height)) // Diagonal izquierda abajo 25
        path.addLine(to: CGPoint(x: 25, y: generalView.bounds.height)) // Hasta la izquierda -25
        path.addLine(to: CGPoint(x: 0, y: generalView.bounds.height-25)) // Diagonal izquierda arriba -25
        path.addLine(to: CGPoint(x: 0, y: 25)) // Punto inicial
        
        // Crear una capa de máscara
        maskLayer.path = path.cgPath
        generalView.layer.mask = maskLayer

        // Crear una capa de borde
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = 1.5
        borderLayer.strokeColor = UIColor(red: 0.38, green: 0.81, blue: 0.31, alpha: 1.0).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor

        // Agregar la capa de borde a la vista
        generalView.layer.addSublayer(borderLayer)
        
        
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
