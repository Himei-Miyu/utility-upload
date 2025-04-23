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
GIT_BRANCH=${4:-main}
IS_COMMIT_SIGN=""
COMMIT_MSG="Refactor Code"
IS_ERROR=0

# functions
log() { echo -e "$@"; }
logContinue() { read -ersp "$(printf $INFO) please enter key to continue"; }

# command requirement
for CMD in ${CMD_REQUIRED[@]}; do
        command -v "$CMD" &> /dev/null || {
                log "$FAIL command $CMD required";
                IS_ERROR=1;
        }
done

[ $IS_ERROR -eq 1 ] && exit 1

# user prompt
[ -z "$GIT_USERNAME" ] && read -p "$(printf $INFO) username : " GIT_USERNAME
[ -z "$GIT_EMAIL" ] && read -p "$(printf $INFO) email : " GIT_EMAIL
[ -z "$GIT_REPO" ] && read -p "$(printf $INFO) repo : " GIT_REPO
read -p "$(printf $INFO) commit sign? (y/N) : " IS_COMMIT_SIGN
read -ei "$COMMIT_MSG" -p "$(printf $INFO) commit message : " COMMIT_MSG

[[ "$IS_COMMIT_SIGN" == "y" ]] && IS_COMMIT_SIGN="yes" || IS_COMMIT_SIGN="no"

# user info
log "$PINK========================"
log "$INFO - username           : $GREEN$GIT_USERNAME"
log     "$INFO - email          : $GREEN$GIT_EMAIL"
log     "$INFO - repository     : $GREEN$GIT_REPO"
log     "$INFO - branch         : $GREEN$GIT_BRANCH"
log     "$INFO - commit-sign    : $GREEN$IS_COMMIT_SIGN"
log "$INFO - commit-message     : $GREEN$COMMIT_MSG"
log "$PINK========================"
logContinue

log "$HMC$RED red$GREEN green$YELLOW yellow"
log "$ALERT alert$SUCCESS success$INFO info"
log "$FAIL fail"
