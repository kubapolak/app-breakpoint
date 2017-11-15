//
//  Message.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class Message {
    private var _content: String
    private var _senderId: String
    private var _time: String
    
    var content: String {
        return _content
    }
    
    var senderId: String {
        return _senderId
    }
    
    var time: String {
        return _time
    }
    
    init(content: String, senderId: String, time: String) {
        self._content = content
        self._senderId = senderId
        self._time = time
    }
}
