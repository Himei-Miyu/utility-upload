#!/bin/bash

# variables
RED="\e[1;38;2;255;150;150m"
PINK="\e[1;38;2;255;192;203m"
WHITE="\e[1;38;2;255;255;255m"
GREEN="\e[1;38;2;150;255;150m"
YELLOW="\e[1;38;2;255;255;150m"
HMC="${PINK}HIMEI${WHITE}-${PINK}CITY ${WHITE}:"
ALERT="\e[1;3;38;2;255;100;100m"
SUCCESS="${WHITE}[${GREEN}✓${WHITE}]"
FAIL="${WHITE}[${RED}X${WHITE}]"
INFO="${WHITE}[${YELLOW}i${WHITE}]"
CMD_REQUIRED=(git ssh gpg);
GIT_USERNAME=$1
GIT_EMAIL=$2
GIT_REPO=$3
GIT_BRANCH=${4:-"main"}
GIT_COMMIT_SIGN="no"
GIT_COMMIT_MSG=${5:-"Refactor Code"}
IS_ERROR=0

# functions
log() { echo -e "$@"; }
logContinue() { read -ersp "$(printf $INFO) please enter key to continue"; }
setInput() { read -p "$(printf $INFO) $1" $2; }
setUsername() { setInput "Username : " GIT_USERNAME; }
setEmail() { setInput "Email : " GIT_EMAIL; }
setBranch() { setInput "Branch : " GIT_BRANCH; }
setRepository() { setInput "Repository : " GIT_REPO; }
setSignature() {
    setInput "Commit Signature (y/N) : " GIT_COMMIT_SIGN;
    [[ "$GIT_COMMIT_SIGN" == "y" ]] && GIT_COMMIT_SIGN="yes" || GIT_COMMIT_SIGN="no"
}
setMessage() { read -ei "$GIT_COMMIT_MSG" -p "$(printf $INFO) Commit Message : " GIT_COMMIT_MSG; }
initialInput() {
    [ -z "$GIT_USERNAME" ] && setUsername
    [ -z "$GIT_EMAIL" ] && setEmail
    [ -z "$GIT_REPO" ] && setRepository
    setSignature
}
changeInput() {
    [[ "$1" == "u" ]] && setUsername
    [[ "$1" == "e" ]] && setEmail
    [[ "$1" == "r" ]] && setRepository
    [[ "$1" == "b" ]] && setBranch
    [[ "$1" == "s" ]] && setSignature
    [[ "$1" == "m" ]] && setMessage
}
logInput() {
    log "$PINK========================"
    log "$INFO - Username           : $GREEN$GIT_USERNAME"
    log "$INFO - Email              : $GREEN$GIT_EMAIL"
    log "$INFO - Repository         : $GREEN$GIT_REPO"
    log "$INFO - Branch             : $GREEN$GIT_BRANCH"
    log "$INFO - Commit Signature   : $GREEN$GIT_COMMIT_SIGN"
    log "$INFO - Commit Message     : $GREEN$GIT_COMMIT_MSG"
    log "$PINK========================"
    setInput "Data Correct? y/N : " IS_CORRECT
    [[ "$IS_CORRECT" == "y" ]] && IS_CORRECT="yes" || IS_CORRECT="no"
    [[ "$IS_CORRECT" == "no" ]] && {
        log "(u)username (e)email (r)repository"
        log "(b)branch   (s)sign  (m)msg"
        setInput "What need change : " GET_CHANGE
        changeInput $GET_CHANGE
        logInput
    }
}
# command requirement
for CMD in ${CMD_REQUIRED[@]}; do
    command -v "$CMD" &> /dev/null || {
        log "$FAIL command $CMD required";
        IS_ERROR=1;
    }
done

[ $IS_ERROR -eq 1 ] && exit 1

# user prompt
initialInput

# user info
logInput

gpg --list-secret-keys --keyid-format long --with-colons | grep -E 'sec|uid' | sed -nE 'N;s/.*:([A-Z0-9]{16}):.*<([^>]*)>.*/\1 \2/p'
