#!/usr/bin/env python

def main(users):
    role_auth = "{}: {},myrole"
    for key, value in users.items():
        sasl_string = role_auth.format(key, value)
        print(sasl_string)


if __name__ == "__main__":
    users = {
        "alice": "bob",
        "user": "pass"
    }
    main(users)
