
public func curry<A, B, C, D, E, F>(
    _ fn: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    
    return { a in { b in { c in { d in { e in fn(a, b, c, d, e) } } } } }
}

public func curry<A, B, C, D, E>(
    _ fn: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E{
    
    return { a in { b in { c in { d in fn(a, b, c, d) } } } }
}

public func curry<A, B, C, D>(
    _ fn: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    
    return { a in { b in { c in fn(a, b, c) } } }
}

public func curry<A, B, C>(
    _ fn: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    
    return { a in { b in fn(a, b) } }
}
