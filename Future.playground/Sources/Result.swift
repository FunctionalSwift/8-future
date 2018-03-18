public enum Result<A, E> {
    case success(_: A)
    case failure(_: E)
    
    public func map<B>(_ transform: (A) -> B) -> Result<B, E> {
        return self.flatMap { .success(transform($0)) }
    }
}

extension Result {
    public func flatMap<B>(_ transform: (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(reason):
            return .failure(reason)
        }
    }
}

extension Result {
    public static func pure(_ value: A) -> Result<A, E> {
        return .success(value)
    }
    
    public func apply<B>(_ resultAB: Result<(A) -> B, E>) -> Result<B, E> {
        return resultAB.flatMap { ab in
            self.map(ab)
        }
    }
}

infix operator <%>: AdditionPrecedence
infix operator <*>: AdditionPrecedence

public func <%><A, B>(_ transform: @escaping (A) -> B, futureA: Future<A>) -> Future<B> {
    return futureA.map(transform)
}

public func <*><A, B>(_ curriedFuture: Future<(A) -> B>, futureA: Future<A>) -> Future<B> {
    return futureA.apply(curriedFuture)
}

public func >>=<A, B>(_ futureA: Future<A>, transform: @escaping (A) -> Future<B>) -> Future<B> {
    return futureA.flatMap(transform)
}
