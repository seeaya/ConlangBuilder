// Copyright (c) Connor Barnes. All rights reserved.

func underlyingType(of value: Any) -> Any.Type {
    if let unwrapped = Mirror(reflecting: value).descendant("some") {
        underlyingType(of: unwrapped)
    } else {
        type(of: value)
    }
}

extension Mirror {
    func descendantMirror(_ first: any MirrorPath, _ rest: any MirrorPath...) -> Mirror? {
        descendant(first, rest: rest).map(Mirror.init(reflecting:))
    }

    func descendant<C: Collection<any MirrorPath>>(_ first: any MirrorPath, rest: C) -> Any? {
        let position: Children.Index? = if case let label as String = first {
            children.firstIndex { $0.label == label }
        } else if let offset = first as? Int {
            children.index(children.startIndex, offsetBy: offset, limitedBy: children.endIndex)
        } else {
            fatalError("Invalid mirror path type. Expected Int or String, but received: \(type(of: first))")
        }

        guard
            let position,
            children.indices.contains(position)
        else { return nil }

        let child = children[position].value

        if let next = rest.first {
            return Mirror(reflecting: child).descendant(next, rest: rest.dropFirst())
        } else {
            return Mirror(reflecting: child)
        }
    }
}
