//
//  CharacterCell.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 11/6/23.
//

import Foundation
import UIKit

class CharacterCell: UITableViewCell {
    
    @IBOutlet weak var vistaContenido: UIView!
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterDetails: UILabel!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    static let identifier = "CharacterCell"
    var characterState: String = ""

    static func nib() -> UINib {
        return UINib(nibName: "CharacterCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vistaContenido.backgroundColor = UIColor.clear
        configurationGeneral()
        configurationStyleView()
        configurationStatusView()
        configurationMainStackView()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backgroundView
    }
        
    func configureWithData(name: String, image: Data, state: String, specie: String) {
        self.characterName.text = name
        self.characterDetails.text = "\(specie) - \(state)"
        self.characterImage.image = UIImage(data: image)
        self.characterState = state
        
        switch characterState {
            case "Alive":
                stateView.backgroundColor = UIColor.green.withAlphaComponent(0.6)
            case "Dead":
            stateView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
            default:
            stateView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        }
        
    }
    
    private func configurationMainStackView() {
        generalView.layer.borderColor = UIColor(red: 0.38, green: 0.81, blue: 0.31, alpha: 1.0).cgColor
        generalView.layer.borderWidth = 1
        
    }
    
    
    private func configurationGeneral() {
        characterDetails.font = UIFont(name: "Retro Gaming", size: 12)
        characterName.font = UIFont(name: "Retro Gaming", size: 20)
        generalView.layer.cornerRadius = 10
        generalView.layer.masksToBounds = true
        generalView.layer.zPosition = -1
    }
    
    private func configurationStyleView() {
        // Crear un trazado de forma triangular
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Punto superior izquierdo
        path.addLine(to: CGPoint(x: generalView.bounds.width-80, y: 0)) // Punto superior derecho
        path.addLine(to: CGPoint(x: generalView.bounds.width, y: 80)) // Punto intermedio derecho
        path.addLine(to: CGPoint(x: generalView.bounds.width, y: generalView.bounds.height)) // Punto inferior derecho
        path.addLine(to: CGPoint(x: 0, y: generalView.bounds.height)) // Punto inferior izquierdo
        path.addLine(to: CGPoint(x: 0, y: 0)) // Punto inicial
        
        // Crear una capa de máscara
        // Aplicar la máscara a la vista
        let maskLayer = CAShapeLayer()
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
    
    private func configurationStatusView() {
        // Obtener el tamaño de la vista cuadrada
        let viewSize = stateView.bounds.size
        stateView.layer.cornerRadius = min(viewSize.width, viewSize.height) / 2.0
        stateView.clipsToBounds = true
    }
    
}
