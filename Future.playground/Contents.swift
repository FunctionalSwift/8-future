//: Playground - Future

import Foundation

func createUser(name: String, password: String, premium: Bool, newsletter: Bool) {
    DispatchQueue.global().async {
        curry(User.init)
            <%> Validators.Name(name)
            <*> Validators.Password(password)
            <*> Result.pure(newsletter)
            <*> Result.pure(premium)
            >>= (UserValidator.Premium || UserValidator.Newsletter)
    }
}
