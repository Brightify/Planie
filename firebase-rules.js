{
    "rules": {
        // Admin can read and write anything unless their account is disabled.
        ".read": "root.child('admins').hasChild(auth.uid) && !root.child('disabledUsers').hasChild(auth.uid)",
        ".write": "root.child('admins').hasChild(auth.uid) && !root.child('disabledUsers').hasChild(auth.uid)",
        "users": {
            // Moderator can get a list of users (including admin accounts).
            ".read": "root.child('moderators').hasChild(auth.uid) && !root.child('disabledUsers').hasChild(auth.uid)",
            "$userId": {
                ".read": "auth.uid == $userId",
                // Users can edit their own information and moderators can edit everyone's but other moderators and admins.
                ".write": "(auth.uid == $userId || (!root.child('moderators').hasChild($userId) && !root.child('admins').hasChild($userId) && root.child('moderators').hasChild(auth.uid))) && !root.child('disabledUsers').hasChild(auth.uid)",
                ".validate": "newData.hasChildren(['id', 'email'])",
                "id": {
                    ".validate": "$userId == newData.val()",
                },
                "email": {
                    ".validate": "newData.val().matches(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$/i)"
                }
            }
        },
        "disabledUsers": {
            "$disabledUserId": {
                // Anyone can get their status and moderators can get status of any user.
                ".read": "auth.uid == $disabledUserId || root.child('moderators').hasChild(auth.uid)",
                // Moderators can disable/enable users, but can't do that for themselves and admins.
                ".write": "root.child('moderators').hasChild(auth.uid) && auth.uid != $disabledUserId && !root.child('admins').hasChild($disabledUserId)",
                ".validate": "root.child('users').hasChild($disabledUserId) && newData.val() == true"
            }
        },
        "moderators": {
            "$moderatorId": {
                ".read": "auth.uid == $moderatorId || (root.child('moderators').hasChild(auth.uid) && !root.child('disabledUsers').hasChild(auth.uid))",
                ".validate": "root.child('users').hasChild($moderatorId) && newData.val() == true"
            }
        },
        "admins": {
            "$adminId": {
                ".read": "auth.uid == $adminId || (root.child('moderators').hasChild(auth.uid) && !root.child('disabledUsers').hasChild(auth.uid))",
                ".validate": "root.child('users').hasChild($adminId) && newData.val() == true"
            }
        },
        "trips": {
            "$userId": {
                ".read": "auth.uid == $userId && !root.child('disabledUsers').hasChild(auth.uid)",
                ".write": "auth.uid == $userId && !root.child('disabledUsers').hasChild(auth.uid)",
                ".indexOn": "begin",
                "$tripId": {
                    ".validate": "newData.hasChildren(['id', 'begin', 'end', 'destination'])",
                    "id": {
                        ".validate": "$tripId == newData.val()"
                    }
                }
            }
        }
    }
}
