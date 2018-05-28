//
//  Messages.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

struct Messages {
    static let firstLaunchEmtpy = """
                                  It looks like you haven't seen any
                                  facts yet, which is unfortunate.

                                  Start by searching for some! If you just want to see a random fact, shake your device.
                                  """

    static let searchResultsEmtpy = "Oops, I couldn't find any facts with that search term."

    static let searchResultsEmtpyOffline = """
                                           It looks like you don't have any facts with that search term on your library.

                                           Connect to the internet to search for new facts from the cloud.
                                           """
}
