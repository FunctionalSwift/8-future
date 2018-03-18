import Foundation

public typealias AsyncResult<A, E> = Future<Result<A, E>>
public typealias Validator<A, E> = (A) -> AsyncResult<A, E>

public func validate<A, E>(_ reason: E, _ condition: @escaping (A) -> Bool) -> Validator<A, E> {
    return { Future.async(condition($0) ? .success($0) : .failure(reason)) }
}

public func &&<A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {
    
    return {
        firstValidator($0).flatMap { resultA in
            switch resultA {
            case let .success(a):
                return secondValidator(a)
            case let .failure(reason):
                return Future.pure(.failure(reason))
            }
        }
    }
}

public func ||<A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {
    
    return { a in
        firstValidator(a).flatMap { result in
            switch result {
            case .success:
                return Future.pure(result)
            case .failure:
                return secondValidator(a)
            }
        }
    }
}
