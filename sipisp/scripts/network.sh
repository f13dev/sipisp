#!/bin/sh

print_usage() {

}

while getopts "m:bx" flag; do
    case "${flag}" in
        m) mode="${OPTARG}" ;;
        b) bridge='true' ;;
        x) bridge='false' ;;
        *) print_usage 
            exit 1 ;;
    esac
done

update_bridge()
{
    
}

add_bridge()
{

}

remove_bridge()
{
    
}