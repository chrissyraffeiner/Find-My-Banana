//
//  SpielerModel.swift
//  findMyBanana
//
//  Created by Administrator on 26.05.20.
//  Copyright © 2020 Laura Riener. All rights reserved.
//

import Foundation

class Spieler {
    var username: String = ""
    var emoji: String = ""
    var punkte: Int = 0
}

class Spielerliste {
    var spieler = [Spieler]()
}
