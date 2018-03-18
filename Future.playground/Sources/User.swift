import Foundation

import Foundation

public struct User {
    public let name: String
    public let password: String
    public let premium: Bool
    public let newsletter: Bool
    
    
    public init(name: String, password: String, premium: Bool, newsletter: Bool) {
        self.name = name
        self.password = password
        self.premium = premium
        self.newsletter = newsletter
    }
    
    public func curryUser(_ name: String) -> (String) -> (Bool) -> (Bool) -> User {
        return {
            password in {
                premium in {
                    newsletter in
                    User(name: name, password: password, premium: premium, newsletter: newsletter)
                }
            }
        }
    }
}

public enum UserError {
    case userNameOutOfBounds
    case passwordTooShort
    case mustBePremium
    case mustAcceptNewsletter
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
}
