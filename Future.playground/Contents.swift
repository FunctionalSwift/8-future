//: Playground - Future

func createUser(name: String, password: String, premium: Bool, newsletter: Bool) -> Result<User, UserError> {
    return curry(User.init)
        <%> Validators.Name(name)
        <*> Validators.Password(password)
        <*> Result.pure(newsletter)
        <*> Result.pure(premium)
        >>= (UserValidator.Premium || UserValidator.Newsletter)
}

let user = createUser(name: "alex", password: "functionalswift", premium: true, newsletter: false)

user.map { print("SUCCESS: User created - \($0)") }
