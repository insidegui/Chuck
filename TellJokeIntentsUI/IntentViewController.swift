//
//  IntentViewController.swift
//  TellJokeIntentsUI
//
//  Created by Guilherme Rambo on 23/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import IntentsUI
import ChuckCore
import NotificationCenter
import os.log

class IntentViewController: UIViewController, INUIHostedViewControlling {

    private let log = OSLog(subsystem: "ChuckIntents", category: "IntentViewController")
    
    @IBOutlet weak var vfxView: UIVisualEffectView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        vfxView.effect = UIVibrancyEffect.widgetPrimary()
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        guard let response = interaction.intentResponse as? TellJokeIntentResponse else {
            os_log("Failed to get response as TellJokeIntentResponse!", log: self.log, type: .fault)
            completion(false, parameters, self.desiredSize)
            return
        }

        os_log("Got response %@", log: self.log, type: .default, String(describing: response))

        label.text = response.body
        view.frame = CGRect(origin: .zero, size: desiredSize)

        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        let maxSize = self.extensionContext!.hostedViewMaximumAllowedSize

        let layoutSize = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)

        return CGSize(width: maxSize.width, height: layoutSize.height)
    }
    
}
