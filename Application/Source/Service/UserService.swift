//
//  UserService.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 07/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import Firebase
import FirebaseDatabase
import Reactant
import Result

final class UserService {

    func users() -> Observable<[UserProfile]> {
        let userList: Observable<[UserProfile]> = FIRDatabase.database().reference()
            .child("users")
            .fetchArray()
            .recover([])

        func addOrReplaceUser(accumulator: [UserProfile], user: UserProfile) -> [UserProfile] {
            var resultantArray = accumulator.filter { $0.id != user.id }
            resultantArray.append(user)
            return resultantArray
        }

        let unsortedResult = userList.flatMapLatest { users in
            Observable.from(users)
                .flatMap(self.setProfileProperties)
                .scan([], accumulator: addOrReplaceUser)
                // This will ensure the list will not be filling up user by user, but only after everything is loaded.
                .filter { $0.count == users.count }
            }

        return unsortedResult.map { $0.sorted { $0.email! < $1.email! } }
    }

    func userRole(userId: String) -> Observable<Role> {
        let ref = FIRDatabase.database().reference()

        return Observable.combineLatest(
            ref.child("moderators").child(userId).exists(),
            ref.child("admins").child(userId).exists()) { isModerator, isAdmin in
                isAdmin ? .admin : isModerator ? .moderator : .user
            }
    }

    func userDisabled(userId: String) -> Observable<Bool> {
        return FIRDatabase.database().reference()
            .child("disabledUsers")
            .child(userId)
            .exists()
    }

    func userProfile(userId: String) -> Observable<Result<UserProfile, FirebaseFetchError>> {
        let user = FIRDatabase.database().reference()
            .child("users")
            .child(userId)
            .fetch(UserProfile.self)

        return user.flatMapLatest { user -> Observable<Result<UserProfile, FirebaseFetchError>> in
            switch user {
            case .success(let profile):
                return self.setProfileProperties(user: profile).map { .success($0) }
            case .failure(let error):
                return .just(.failure(error))
            }
        }
    }

    func setAccountDisabled(user: UserProfile, disabled: Bool) -> Observable<Bool> {
        let path = FIRDatabase.database().reference().child("disabledUsers").child(user.id)

        return Observable.create { observer in
            if disabled {
                path.setValue(true) { error, reference in
                    observer.onLast(error == nil)
                }
            } else {
                path.removeValue { error, reference in
                    observer.onLast(error == nil)
                }
            }
            return Disposables.create()
        }
    }

    func setAccountRole(user: UserProfile, role: Role) -> Observable<Bool> {
        guard user.role != role else { return .just(false) }

        return Observable.create { observer in
            let ref = FIRDatabase.database().reference()

            let removalCompletion: (Error?, FIRDatabaseReference) -> Void = { error, _ in
                observer.onLast(error == nil)
            }
            let addCompletion: (Error?, FIRDatabaseReference) -> Void = { error, _ in
                guard error == nil else {
                    observer.onLast(false)
                    return
                }

                switch user.role {
                case .admin:
                    ref.child("admins").child(user.id).removeValue(completionBlock: removalCompletion)
                case .moderator:
                    ref.child("moderators").child(user.id).removeValue(completionBlock: removalCompletion)
                case .user:
                    removalCompletion(nil, ref)
                }
            }

            switch role {
            case .admin:
                ref.child("admins").child(user.id).setValue(true, withCompletionBlock: addCompletion)
            case .moderator:
                ref.child("moderators").child(user.id).setValue(true, withCompletionBlock: addCompletion)
            case .user:
                addCompletion(nil, ref)
            }

            return Disposables.create()
        }
    }

    private func setProfileProperties(user: UserProfile) -> Observable<UserProfile> {
        let role = self.userRole(userId: user.id)
        let disabled = self.userDisabled(userId: user.id)
        return Observable.combineLatest(role, disabled) { role, disabled in
            var mutableUser = user
            mutableUser.role = role
            mutableUser.disabled = disabled
            return mutableUser
        }
    }
}
