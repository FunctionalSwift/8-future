//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func createUser(name: String, password: String, premium: Bool, newsletter: Bool) -> AsyncResult<User, UserError> {
    return curry(User.init)
        <%> Validators.Name(name)
        <*> Validators.Password(password)
        <*> Future.pure(Result.pure(newsletter))
        <*> Future.pure(Result.pure(premium))
        >>= (UserValidator.Premium || UserValidator.Newsletter)
}

createUser(name: "alex", password: "functionalswift", premium: true, newsletter: true)
    .runSync()
    .map { print($0) }
