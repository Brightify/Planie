//
//  LoginService.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 03/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import Firebase
import Reactant
import Result

final class LoginService {

    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    func login(email: String, password: String) -> Observable<Result<UserProfile, FirebaseLoginError>> {
        return Observable<Result<FIRUser, FirebaseLoginError>>
            .create { observer in
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { user, error in
                    if let user = user {
                        observer.onLast(.success(user))
                    } else if let error = error {
                        observer.onLast(.failure(FirebaseLoginError(error: error as NSError)))
                    } else {
                        observer.onLast(.failure(.common(.unknown)))
                    }
                }
                return Disposables.create()
            }
            .flatMapLatest { [userService] login -> Observable<Result<FIRUser, FirebaseLoginError>> in
                switch login {
                case .success(let user):
                    return userService.userDisabled(userId: user.uid)
                        .take(1)
                        .map { $0 ? .failure(.userDisabled) : .success(user) }
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
            .flatMapLatest { [userService] login -> Observable<Result<UserProfile, FirebaseLoginError>> in
                switch login {
                case .success(let user):
                    return userService.userProfile(userId: user.uid).mapError { _ in .common(.internalError) }
                case .failure(let error):
                    return .just(.failure(error))
                }
        }
    }

    func logout() -> Observable<Result<Void, FirebaseCommonError>> {
        do {
            try FIRAuth.auth()?.signOut()
            return .just(.success(()))
        } catch {
            let firebaseError = FirebaseCommonError(error: error as NSError)
            return .just(.failure(firebaseError))
        }
    }

    func register(email: String, password: String) -> Observable<Result<UserProfile, FirebaseSignupError>> {
        return Observable<Result<UserProfile, FirebaseSignupError>>.create { observer in
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { user, error in
                if let user = user {
                    let profile = UserProfile(id: user.uid, email: user.email)
                    observer.onLast(.success(profile))
                } else if let error = error {
                    observer.onLast(.failure(FirebaseSignupError(error: error as NSError)))
                } else {
                    observer.onLast(.failure(.common(.unknown)))
                }
            }
            return Disposables.create()
            }.flatMapLatest { registration -> Observable<Result<UserProfile, FirebaseSignupError>> in
                switch registration {
                case .success(let profile):
                    return FIRDatabase.database().reference()
                        .child("users")
                        .store(profile, forKey: profile.id)
                        .mapValue { $0.object }
                        .mapError { _ in .common(.internalError) }
                case .failure(let error):
                    return .just(.failure(error))
                }
        }
    }
}
