//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//
import Foundation
import UIKit
import Combine

class ViewController: UIViewController {
    let useCase: CheckUseCase
    private var bag = Set<AnyCancellable>()
    
    init(useCase: CheckUseCase) {
        self.useCase = useCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

    }

    deinit {
        print("ViewController - DEINIT")
    }
    
}
