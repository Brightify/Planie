//
//  Firebase+Rx.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 1/11/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import FirebaseDatabase
import RxSwift
import DataMapper
import Reactant
import Result

protocol FirebaseEntity {
    var id: String? { get set }
}

protocol FirebaseValue {
    associatedtype FirebaseRepresentationType

    func serialize() -> FirebaseRepresentationType?

    static func deserialize(firebaseValue: FirebaseRepresentationType) -> Self?
}

extension String: FirebaseValue {
    typealias FirebaseRepresentationType = String

    func serialize() -> FirebaseRepresentationType? {
        return self
    }

    static func deserialize(firebaseValue: FirebaseRepresentationType) -> String? {
        return firebaseValue
    }
}

enum FirebaseFetchError: Error {
    case deserializeError(FIRDataSnapshot)
    case readDenied(Error)
}

enum FirebaseStoreError: Error {
    case serializeError
    case writeDenied(Error)
}

import FirebaseDatabase

extension FIRServerValue {
    static var swiftTimestamp: [String: String] {
        let timestamp = self.timestamp()
        let key = timestamp.keys.first?.description ?? ".sv"
        let value = timestamp[key] as? String ?? "timestamp"
        return [key: value]
    }
}

private let jsonSerializer = JsonSerializer()
private let objectMapper = ObjectMapper()

extension FIRDatabaseQuery {
    func exists() -> Observable<Bool> {
        return Observable.create { observer in
            let handle = self.observe(.value,
                                      with: { snapshot in
                                        observer.onNext(snapshot.exists())
            },
                                      withCancel: { _ in
                                        observer.onLast(false)
            })
            return Disposables.create {
                self.removeObserver(withHandle: handle)
            }
        }
    }

    func fetch<T: FirebaseValue>(_: T.Type = T.self, event: FIRDataEventType = .value)
        -> Observable<Result<T, FirebaseFetchError>> {
            return Observable.create { observer in
                let handle = self.observe(event, with: { snapshot in
                    if let
                        snapshotValue = snapshot.value as? T.FirebaseRepresentationType,
                        let object = T.deserialize(firebaseValue: snapshotValue) {
                        observer.onNext(.success(object))
                    } else {
                        observer.onNext(.failure(.deserializeError(snapshot)))
                    }
                }, withCancel: { error in
                    observer.onLast(.failure(.readDenied(error)))
                })
                return Disposables.create {
                    self.removeObserver(withHandle: handle)
                }
            }
    }

    func fetch<T: Deserializable>(_: T.Type = T.self, event: FIRDataEventType = .value)
        -> Observable<Result<T, FirebaseFetchError>> {
            return Observable.create { observer in
                let handle = self.observe(event, with: { snapshot in
                    if let
                        snapshotDictionary = snapshot.value as? [String: AnyObject],
                        let object: T = objectMapper.deserialize(jsonSerializer.typedDeserialize(snapshotDictionary)) {
                        observer.onNext(.success(object))
                    } else {
                        observer.onNext(.failure(.deserializeError(snapshot)))
                    }
                }, withCancel: { error in
                    observer.onLast(.failure(.readDenied(error)))
                })
                return Disposables.create {
                    self.removeObserver(withHandle: handle)
                }
            }
    }

    func fetchArray<T: Deserializable>(_: T.Type = T.self) -> Observable<Result<[T], FirebaseFetchError>> {
        return Observable.create { observer in
            let handle = self.observe(.value, with: { snapshot in
                let array = snapshot.children.flatMap { child -> T? in
                    guard let
                        childSnapshot = child as? FIRDataSnapshot,
                        let childDictionary = childSnapshot.value as? [String: AnyObject] else { return nil }
                    return objectMapper.deserialize(jsonSerializer.typedDeserialize(childDictionary))
                }
                observer.onNext(.success(array))
            }, withCancel: { error in
                observer.onLast(.failure(.readDenied(error)))
            })
            return Disposables.create {
                self.removeObserver(withHandle: handle)
            }
        }
    }
}

extension FIRDatabaseReference {
    func store<T: Serializable>(_ objects: [T]) -> Observable<[Result<T, FirebaseStoreError>]> where T: FirebaseEntity {
        return Observable.from(objects.map(store)).concat().reduce([]) { accumulator, result in
            accumulator + [result]
        }
    }

    func store<T: Serializable>(_ object: T) -> Observable<Result<T, FirebaseStoreError>> where T: FirebaseEntity {
        return Observable.create { observer in
            var mutableObject = object
            let key: String
            if let id = mutableObject.id {
                key = id
            } else {
                key = self.childByAutoId().key
                mutableObject.id = key
            }

            guard let dictionary = jsonSerializer.typedSerialize(objectMapper.serialize(mutableObject)) as? [String: Any] else {
                observer.onLast(.failure(.serializeError))
                return Disposables.create()
            }

            self.child(key).setValue(dictionary) { error, reference in
                if let error = error {
                    observer.onLast(.failure(.writeDenied(error)))
                } else {
                    observer.onLast(.success(mutableObject))
                }
            }
            return Disposables.create()
        }
    }

    func store<T: Serializable>(_ object: T, forKey key: String? = nil) ->
        Observable<Result<(key: String, object: T), FirebaseStoreError>> {
            return Observable.create { observer in
                guard var dictionary = jsonSerializer.typedSerialize(objectMapper.serialize(object)) as? [String: Any]  else {
                    observer.onLast(.failure(.serializeError))
                    return Disposables.create()
                }

                let childKey = key ?? self.childByAutoId().key

                dictionary["id"] = childKey

                self.child(childKey).setValue(dictionary) { error, reference in
                    if let error = error {
                        observer.onLast(.failure(.writeDenied(error)))
                    } else {
                        observer.onLast(.success((key: childKey, object: object)))
                    }
                }
                return Disposables.create()
            }
    }

    func delete<T: Serializable>(_ object: T) -> Observable<Result<Void, FirebaseStoreError>> where T: FirebaseEntity {
        return Observable.create { observer in
            guard let key = object.id else {
                observer.onLast(.success())
                return Disposables.create()
            }

            self.child(key).removeValue { error, reference in
                if let error = error {
                    observer.onLast(.failure(.writeDenied(error)))
                } else {
                    observer.onLast(.success())
                }
            }
            return Disposables.create()
        }
        
    }
}
