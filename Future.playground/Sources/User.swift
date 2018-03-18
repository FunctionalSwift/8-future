import Foundation

import Foundation

public struct User {
    let name: String
    let password: String
    let premium: Bool
    let newsletter: Bool
    let birthday: Date
    let email: String
    
    public init(name: String, password: String, premium: Bool, newsletter: Bool, birthday: Date, email: String) {
        self.name = name
        self.password = password
        self.premium = premium
        self.newsletter = newsletter
        self.birthday = birthday
        self.email = email
    }
    
    public func curryUser(_ name: String) -> (String) -> (Bool) -> (Bool) -> (Date) -> (String) -> User {
        return {
            password in {
                premium in {
                    newsletter in {
                        birthday in {
                            email in
                            User(name: name, password: password, premium: premium, newsletter: newsletter, birthday: birthday, email: email)
                        }
                    }
                }
            }
        }
    }
}

public enum UserError {
    case passwordTooShort
    case userNameOutOfBounds
    case mustBePremium
    case mustAcceptNewsletter
    case mustBeAdult
    case wrongEmail
}

public class UserValidator {
    
    public class var Premium: Validator<User, UserError> {
        return validate(.mustBePremium) {
            $0.premium
        }
    }
    
    public class var Newsletter: Validator<User, UserError> {
        return validate(.mustAcceptNewsletter) {
            $0.newsletter
        }
    }
}

public class Validators {
    public class var Name: Validator<String, UserError> {
        return validate(.userNameOutOfBounds) {
            !$0.isEmpty && $0.count <= 15
        }
    }
    
    public class var Password: Validator<String, UserError> {
        return validate(.passwordTooShort) {
            $0.count > 10
        }
    }
    
    public class var Adult: Validator<Date, UserError> {
        return validate(.mustBeAdult) {
            guard let years = Calendar.current.dateComponents([.year], from: $0, to: Date()).year else { return false }
            return years >= 18
        }
    }
    
    public class var Email: Validator<String, UserError> {
        return validate(.wrongEmail) {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
            return predicate.evaluate(with: $0)
        }
    }
}
