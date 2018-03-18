import Foundation

public typealias Validator<A, E> = (A) -> Result<A, E>

func validate<A, E>(_ reason: E, _ condition: @escaping (A) -> Bool) -> Validator<A, E> {
    return { condition($0) ? .success($0) : .failure(reason) }
}

public func &&<A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {
    
    return { firstValidator($0).flatMap(secondValidator) }
}

public func ||<A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {
    
    return { a in
        let result = firstValidator(a)
        switch result {
        case .success:
            return result
        case .failure:
            return secondValidator(a)
        }
    }
}
