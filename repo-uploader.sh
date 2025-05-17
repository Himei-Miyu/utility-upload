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
GIT_INITIAL=""
GIT_USERNAME=""
GIT_EMAIL=""
GIT_REPO=""
GIT_BRANCH=""
GIT_COMMIT_SIGN=""
GIT_COMMIT_MSG=""
IS_ERROR=0

# functions
log() { echo -e "$@"; }
logContinue() { read -ersp "$(printf $INFO) please enter key to continue"; }
setInput() { read -p "$(printf $INFO) $1" $2; }
setInput::choice() { read -n $1 -p "$(printf $INFO) $2" $3;echo; }
setInput::validateYes() { [[ "${!1}" == "y" ]] && eval "$1='yes'" || eval "$1='no'"; }
setUsername() { setInput "Username : " GIT_USERNAME; }
setEmail() { setInput "Email : " GIT_EMAIL; }
setBranch() { setInput "Branch : " GIT_BRANCH; }
setRepository() { setInput "Repository : " GIT_REPO; }
setSignature() {
  setInput::choice 1 "Commit Signature (y/N) : " GIT_COMMIT_SIGN;
  setInput::validateYes GIT_COMMIT_SIGN;
}
setMessage() { read -ei "$GIT_COMMIT_MSG" -p "$(printf $INFO) Commit Message : " GIT_COMMIT_MSG; }
getInput() {
  case "$1" in
    "GIT_USERNAME")
      GIT_USERNAME=$(git config user.name);
      [ -z "$GIT_USERNAME" ] && setUsername;;
    "GIT_EMAIL")
      GIT_EMAIL=$(git config user.email);
      [ -z "$GIT_EMAIL" ] && setEmail;;
    "GIT_REPO")
      GIT_REPO=$(git remote get-url origin --push &> /dev/null| sed -nE 's/.*\/(.+)\..*/\1/p');
      [ -z "$GIT_REPO" ] && setRepository;;
    "GIT_BRANCH")
      GIT_BRANCH=$(git branch &> /dev/null | grep -E '^\*' | sed -nE 's/^\*\s(.*)$/\1/p');
      [ -z "$GIT_BRANCH" ] && GIT_BRANCH="main";;
    *)
      log "$FAIL$ALERT Input incorrect";
      exit 0;;
  esac
}
initialInput() {
  [ -z "$GIT_USERNAME" ] && getInput GIT_USERNAME
  [ -z "$GIT_EMAIL" ] && getInput GIT_EMAIL
  [ -z "$GIT_REPO" ] && getInput GIT_REPO
  [ -z "$GIT_BRANCH" ] && getInput GIT_BRANCH
  [ -z "$GIT_COMMIT_SIGN" ] && setSignature
  [ -z "$GIT_COMMIT_MSG" ] && GIT_COMMIT_MSG="✨ Refactor Code"
  setMessage
}
changeInput() {
  case "$1" in
    "u") setUsername && return 0;;
    "e") setEmail && return 0;;
    "b") setBranch && return 0;;
    "r") setRepository && return 0;;
    "s") setSignature && return 0;;
    "m") setMessage && return 0;;
    *) changeInput::loop;;
  esac
}
changeInput::loop() {
  local INPUT
  log "(u)username (e)email (r)repository"
  log "(b)branch   (s)sign  (m)msg"
  setInput::choice 1 "What need change : " INPUT
  changeInput $INPUT
}
logInput() {
  local INPUT
  log "$PINK========================"
  log "$INFO - Username           : $GREEN$GIT_USERNAME"
  log "$INFO - Email              : $GREEN$GIT_EMAIL"
  log "$INFO - Repository         : $GREEN$GIT_REPO"
  log "$INFO - Branch             : $GREEN$GIT_BRANCH"
  log "$INFO - Commit Signature   : $GREEN$GIT_COMMIT_SIGN"
  log "$INFO - Commit Message     : $GREEN$GIT_COMMIT_MSG"
  log "$PINK========================"
  setInput::choice 1 "Data Correct? y/N : " INPUT
  setInput::validateYes $INPUT
  [[ "$INPUT" == "no" ]] && changeInput::loop && logInput
}
optionInput::setOverride() {
  local INPUT_FILTERED=($(echo $@ | sed 's/\s*-[^ ]*//g'))
  GIT_USERNAME=${INPUT_FILTERED[0]}
  GIT_EMAIL=${INPUT_FILTERED[1]}
  GIT_REPO=${INPUT_FILTERED[2]}
  GIT_BRANCH=${INPUT_FILTERED[3]}
  GIT_COMMIT_MSG=${INPUT_FILTERED[@]:4}
}
optionInput::setOption() {
  local INPUT_FILTERED=($(echo $@ | grep -o '\-[^ ]*'))
  for OPT in ${INPUT_FILTERED[@]}; do
    case "$OPT" in
      "-i"|"-init"|"--initial") GIT_INITIAL="yes";;
      "-s"|"-sign"|"--signature") GIT_COMMIT_SIGN="yes";;
      "-h"|"--help") optionInput::help; exit 0;;
      *) log "$FAIL$ALERT Option invalid, type '--help' see help"; exit 1;;
    esac
  done
}
optionInput::help() {
  log "Syntax: [OPTION] USERNAME EMAIL REPOSITORY BRANCH COMMIT_MESSAGE"
  log "Options:"
  log " -i, -init, --initial          make initial git"
  log " -s, -sign, --signature        use signature with commit"
  log " -h, --help                    how to use command"
}
############################################
##
## REPO-UPLOADER SCRIPT
##
############################################

# command requirement
for CMD in ${CMD_REQUIRED[@]}; do
  command -v "$CMD" &> /dev/null || {
    log "$FAIL command $CMD required";
    IS_ERROR=1;
  }
done

[ $IS_ERROR -eq 1 ] && exit 1

optionInput() {
  optionInput::setOverride $@
  optionInput::setOption $@
}

optionInput $@

# user prompt
initialInput

# user info
logInput

#TODO Make ssh condition more
# SSH Required
SSH_PRIVATE_KEY="$HOME/.ssh/github-$GIT_USERNAME"
SSH_PUBLIC_KEY="$SSH_PRIVATE_KEY.pub"
eval "$(ssh-agent -s)" &> /dev/null
ssh-add $SSH_PRIVATE_KEY 2> /dev/null || {
  log "$INFO SSH Key not found"
  log "(u)use my key   (n)new key"
  setInput::choice 1 "Choose option : " IS_SSH_KEY
  [[ "$IS_SSH_KEY" == "u" ]] && {
    log "$INFO My file name SSH private key"
    ls -A ~/.ssh | grep -vE 'known_hosts|authorized_keys|\.pub'
    setInput "File name : " SSH_PRIVATE_KEY_FILE_NAME
    ssh-add ~/.ssh/$SSH_PRIVATE_KEY_FILE_NAME &> /dev/null
    log "SSH Section Finished"
  }
}
ssh -T git@github.com 2>&1 | grep -E 'successfully' | sed -nE 's/.*\s(.+)!.*/\1/p'

# GPG Required
#gpg --list-secret-keys --keyid-format long --with-colons | grep -E 'sec|uid' | sed -nE 'N;s/.*:([A-Z0-9]{16}):.*<([^>]*)>.*/\1 \2/p'

# Git Initial
[ "$GIT_INITIAL" ] && {
  [ -d ".git" ] && {
    log "This folder is git repository"
    setInput::choice 1 "need force initial? (y/N) : " IS_INITIAL
    setInput::validateYes IS_INITIAL
    [[ "$IS_INITIAL" == "yes" ]] && {
      rm -rf .git
      git init
    }
    exit 0
  }
  git init
}

log "Run script repo-uploader completed."
