//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func createUser(name: String, password: String, premium: Bool, newsletter: Bool, _ completion: @escaping (Result<User, UserError>) -> Void) {
    DispatchQueue.global().async {
        let result = curry(User.init)
            <%> Validators.Name(name)
            <*> Validators.Password(password)
            <*> Result.pure(newsletter)
            <*> Result.pure(premium)
            >>= (UserValidator.Premium || UserValidator.Newsletter)
        
        completion(result)
    }
}

createUser(name: "alex", password: "functionalSwift", premium: true, newsletter: true) { result in
    result.map { print($0) }
}
