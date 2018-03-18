import Foundation

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

public func <%><A, B, E>(_ transform: @escaping (A) -> B, asyncResultA: AsyncResult<A, E>) -> AsyncResult<B, E> {
    return asyncResultA.map { result in
        result.map(transform)
    }
}

public func <*><A, B, E>(_ asyncResultAB: AsyncResult<(A) -> B, E>, asyncResultA: AsyncResult<A, E>) -> AsyncResult<B, E> {
    return asyncResultA.map2(asyncResultAB) { (resultA, resultAB) in
        resultA.apply(resultAB)
    }
}

public func >>=<A, B, E>(_ asyncResultA: AsyncResult<A, E>, transform: @escaping (A) -> AsyncResult<B, E>) -> AsyncResult<B, E> {
    return asyncResultA.flatMap { resultA in
        switch resultA {
        case let .success(a):
            return transform(a)
        case let .failure(reason):
            return Future.pure(.failure(reason))
        }
    }
}

