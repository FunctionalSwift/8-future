//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func createUser(name: String, password: String, premium: Bool, newsletter: Bool, birthday: Date, email: String) -> AsyncResult<User, UserError> {
    return curry(User.init)
        <%> Validators.Name(name)
        <*> Validators.Password(password)
        <*> Future.pure(Result.pure(newsletter))
        <*> Future.pure(Result.pure(premium))
        <*> Validators.Adult(birthday)
        <*> Validators.Email(email)
        >>= (UserValidator.Premium || UserValidator.Newsletter)
}

let birthday = Date(timeIntervalSince1970: 42)

createUser(name: "alex", password: "functionalswift", premium: true, newsletter: true, birthday: birthday, email: "alex.swift@swiftfuncional.com")
    .runSync()
    .map { print($0) }
