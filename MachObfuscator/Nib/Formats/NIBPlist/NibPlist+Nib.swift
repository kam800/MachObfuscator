import Foundation

extension NibPlist: Nib {
    var selectors: [String] {
        return contents.connectionLabels
    }

    var classNames: [String] {
        return contents.classNames
    }

    mutating func modifySelectors(withMapping map: [String: String]) {
        let connectionLabelIndices = contents.connectionLabelIndices
        let connectionLabels = contents.connectionLabels
        zip(connectionLabelIndices, connectionLabels).compactMap { labelIndex, label in
            map[label].flatMap { mappedLabel in (labelIndex, mappedLabel) }
        }.forEach { labelIndex, mappedLabel in
            contents.replace(objectAt: labelIndex, with: mappedLabel)
        }
    }

    mutating func modifyClassNames(withMapping map: [String: String]) {
        let classNameIndices = contents.classNameIndices
        let classNames = contents.classNames
        zip(classNameIndices, classNames).compactMap { classNameIndex, className in
            map[className].flatMap { mappedName in (classNameIndex, mappedName) }
        }.forEach { classNameIndex, mappedName in
            contents.replace(objectAt: classNameIndex, with: mappedName)
        }
    }
}

private extension Dictionary where Key == String, Value == Any {
    var topIBObjectIndex: Int {
        let topDictionary = self["$top"] as! [String: Any]
        let objectdataRef = topDictionary["IB.objectdata"]!
        return CFKeyedArchiverUIDGetValue(objectdataRef)
    }

    var objects: [Any] {
        return self["$objects"] as! [Any]
    }

    func object(atIndex index: Int) -> Any {
        return objects[index]
    }

    var topObject: [String: Any] {
        return object(atIndex: topIBObjectIndex) as! [String: Any]
    }

    var connectionsIndex: Int {
        return CFKeyedArchiverUIDGetValue(topObject["NSConnections"]!)
    }

    var connectionsObject: [String: Any] {
        return object(atIndex: connectionsIndex) as! [String: Any]
    }

    var connectionIndices: [Int] {
        return (connectionsObject["NS.objects"] as! [Any])
            .map(CFKeyedArchiverUIDGetValue)
    }

    var connectionObjects: [[String: Any]] {
        return connectionIndices.map { index in
            self.object(atIndex: index) as! [String: Any]
        }
    }

    // TODO: bindings
    var connectionLabelIndices: [Int] {
        // TODO: this used to be:
        //   connectionObjects.map { connectionObject in
        //     CFKeyedArchiverUIDGetValue(connectionObject["NSLabel"]!)
        return connectionObjects.compactMap { connectionObject in
            connectionObject["NSLabel"].flatMap(CFKeyedArchiverUIDGetValue)
        }
    }

    var connectionLabels: [String] {
        return connectionLabelIndices.map { connectionLabelIndex in
            object(atIndex: connectionLabelIndex) as! String
        }
    }

    var classNameIndices: [Int] {
        return objects.compactMap { $0 as? [String: Any] }
            .compactMap { $0["NSClassName"] }
            .map(CFKeyedArchiverUIDGetValue)
    }

    var classNames: [String] {
        return classNameIndices.map(object(atIndex:))
            .map { $0 as! String }
    }

    mutating func replace(objectAt index: Int, with replacement: Any) {
        var objectsArray = self["$objects"] as! [Any]
        objectsArray[index] = replacement
        self["$objects"] = objectsArray
    }
}
