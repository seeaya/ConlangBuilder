// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

@Model
class PartOfSpeech {
    var conName: String
    var localName: String
    var userDescription: String

    init(conName: String = "", localName: String = "", userDescription: String = "") {
        self.conName = conName
        self.localName = localName
        self.userDescription = userDescription
    }
}
