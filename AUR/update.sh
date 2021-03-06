#!/bin/bash
verbose=false
minimal=false
update=false
noconfirm=false

for arg in "$@"; do
    if [[ $arg == "-v" ]] || [[ $arg == "--verbose" ]]; then
        verbose=true
    elif [[ $arg == "-m" ]] || [[ $arg == "--minimal" ]]; then
        minimal=true
    elif [[ $arg == "-u" ]] || [[ $arg == "--update" ]]; then
        update=true
    elif [[ $arg == "--noconfirm" ]]; then
        noconfirm=true
    elif [[ $arg == "-h" ]] || [[ $arg == "--help" ]]; then
        echo "Helper script for the AUR directory, which tells you what packages need an update.
Usage: ./update.sh [options]
Options:
-v, --verbose      Don't suppress the output of any command run within the script.
-m, --minimal      Only show directories in need for an update.
-u, --update       If an update is needed, pull the new updates, 'makepkg -si' and afterwards 'git reset HEAD --hard' and 'git clean -fdx'.
    --noconfirm    Pass the --noconfirm option to 'makepkg -si', if using the -u/--update option"
        exit 0
    fi
done

for dir in *; do
    if [ -d "$dir" ]; then
        cd $dir
        if $verbose; then
            git fetch --all
        else
            git fetch --all > /dev/null
        fi

        BEHIND=$(git rev-list HEAD...origin/master --count)
        if [[ $BEHIND -eq 0 ]]; then
            if ! $minimal; then
                echo "[ ] $(pwd) is up to date"
            fi
        else
            echo "[X] $(pwd) is $BEHIND commits behind"

            if $update; then
                if $verbose; then
                    git pull --all
                else
                    git pull --all > /dev/null
                fi

                if $noconfirm; then
                    if $verbose; then
                        makepkg -si --noconfirm
                    else
                        makepkg -si --noconfirm > /dev/null
                    fi
                else
                    if $verbose; then
                        makepkg -si
                    else
                        makepkg -si > /dev/null
                    fi
                fi

                if $verbose; then
                    git reset HEAD --hard
                    git clean -fdx
                else
                    git reset HEAD --hard > /dev/null
                    git clean -fdx > /dev/null
                fi
            fi
        fi

        cd ..
    fi
done
