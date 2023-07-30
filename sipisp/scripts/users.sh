#!/bin/sh

# Manage user accounts for SipISP
print_usage() {
    printf "\nUsage:"
    printf "\n-m MODE list | add | delete | password"
    printf "\n-u USER string"
    printf "\n-p PASS string"
    printf "\n"
}

while getopts "m:u:p:" flag; do
    case "${flag}" in
        m) mode="${OPTARG}" ;;
        u) user="${OPTARG}" ;;
        p) pass="${OPTARG}" ;;
        v) verbose='true' ;;
        *) print_usage
            exit 1 ;;
    esac
done

list_users()
{
    cat /etc/passwd
}

add_user()
{
    # Check that a user is set

    if [ -z "$user" ]
    then
        echo "Error: could not create user"
        echo "A user must be provided with the -u flag"
        return 1
    fi

    #check that a password is set

    if [ -z "$pass" ]
    then
        echo "Error: could not create user"
        echo "A password must be provided with the -p flag"
        return 1
    fi

    # A user can now be created

    echo "Attempting to create a user with the name $user"

    # Attempt to create user
    sudo useradd -m "$user"

    # Set users password

    change_user_password
}

delete_user()
{
    # Check that a user is set

    if [ -z "$user" ]
    then
        echo "Error: could not delete user"
        echo "A user must be provided with the -u flag"
        return 1
    fi

    # A user can be deleted

    echo "Attempting to delete user $user"

    # Attempt to delete the user

    sudo userdel -r "$user"

    # find line in /etc/ppp/pap-secrets that is "#$user account"
    # Delete it and the line following it (the actual pap user record)
    sudo sed -i "/#$user sipisp/,+1 d" /etc/ppp/pap-secrets

}

change_user_password()
{
    # Check that a user is set

    if [ -z "$user" ]
    then
        echo "Error: could not change user password"
        echo "A user must be provided with the -u flag"
        return 1
    fi

    # Check that a password is set

    if [ -z "$pass" ]
    then
        echo "Error: could not change user password"
        echo "A password must be provided with the -p flag"
    fi

    # A user password can be updated

    echo "Attempting to change the password of $user to $pass"

    # Attempt to change password
    
    sudo usermod --password $(echo "$pass" | openssl passwd -1 -stdin) "$user"

    # find line in /etc/ppp/pap-secrets that is "#$user account"
    # Delete it and the line following it (the actual pap user record)
    sudo sed -i "/#$user sipisp/,+1 d" /etc/ppp/pap-secrets

    sudo cat <<EOF >> /etc/ppp/pap-secrets
#$user sipisp
$user   *   "$pass" *
EOF
}

case "$mode" in
    "list") list_users 
    ;;
    "add") add_user 
    ;;
    "delete") delete_user
    ;;
    "password") change_user_password
    ;;
esac