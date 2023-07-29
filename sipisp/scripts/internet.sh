#!/bin/sh

# Manage internet settings
print_usage() {

}

while getopts "m:y:" flag; do
    case "${flag}" in
        m) mode="${OPTARG}" ;;
        y) year="${OPTARG}" ;;
        *) print_usage
            exit 1 ;;
    esac
done

change_year()
{
    
}