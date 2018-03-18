//: Playground - Future

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func createUser(name: String, password: String, premium: Bool, newsletter: Bool) -> Result<User, UserError> {
    
    let group = DispatchGroup()
    
    var nameResult: Result<String, UserError>?
    var passwordResult: Result<String, UserError>?
    
    DispatchQueue.global().async(group: group) {
        nameResult = Validators.Name(name)
    }
    
    DispatchQueue.global().async(group: group) {
        passwordResult = Validators.Password(password)
    }
    
    group.wait()
    
    return curry(User.init)
        <%> nameResult!
        <*> passwordResult!
        <*> Result.pure(newsletter)
        <*> Result.pure(premium)
        >>= (UserValidator.Premium || UserValidator.Newsletter)
}


createUser(name: "alex", password: "functionalSwift", premium: true, newsletter: true)
    .map { print($0) }
