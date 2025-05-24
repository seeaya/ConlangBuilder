// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

@Model
public class PartOfSpeech {
    public var conName: String
    public var localName: String
    public var userDescription: String

    public init(conName: String = "", localName: String = "", userDescription: String = "") {
        self.conName = conName
        self.localName = localName
        self.userDescription = userDescription
    }
}
