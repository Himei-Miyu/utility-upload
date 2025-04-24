#!/bin/bash

upload() {
	# declare variables
    local -a COMMANDS=(ssh git);
    local RED="\e[1;38;2;255;0;0m"
    local PINK="\e[1;38;2;255;192;203m"
    local WHITE="\e[1;38;2;255;255;255m"
    local GREEN="\e[1;38;2;0;255;0m"
    local YELLOW="\e[1;38;2;255;255;0m"
    local HMC="${PINK}HIMEI${WHITE}-${PINK}CITY ${WHITE}>";
	local ALERT="\e[1;3;38;2;255;100;100m"
    local SUCCESS="${WHITE}[${GREEN}✓${WHITE}]"
    local FAIL="${WHITE}[${RED}X${WHITE}]"
    local INFO="${WHITE}[${YELLOW}i${WHITE}]"
	local REGEX_USERNAME='^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$';
	local REGEX_EMAIL='^[a-zA-Z0-9._-]+@[a-zA-Z0-9._]+\.[a-z]{2,}$';
	local REGEX_REPO='[a-z0-9._-]+';
	local SSH_KEY="$HOME/.ssh/github_$1";
    local SSH_DIR="$HOME/.ssh";
	local DEFAULT_MSG="✨ Refactor Code"
	local IS_EDITOR="$(command -v micro 2&> /dev/null && echo 'micro' || echo 'nano' )"
	function openWebsite() {
		echo -e "$INFO SSH Key required by github website" \
		        "\n$INFO SSH Key copied to clipboard" \
		        "\n$INFO Opening github website" \
		        "\n$INFO Ensure SSH key has been added to github website"
		sleep 2;
		[[ $OSTYPE == "msys" ]] && cat "$SSH_KEY.pub" | clip && start "https://github.com/settings/ssh/new";
		[[ $OSTYPE == "linux-android" ]] && cat "$SSH_KEY.pub" | termux-clipboard-set && termux-open-url "https://github.com/settings/ssh/new";
		[[ $OSTYPE == "linux-gnu" ]] && cat "$SSH_KEY.pub" | xclip -selection clipboard && xdg-open "https://github.com/settings/ssh/new";
		read -p "$(printf $INFO) press enter key to continue";
		ssh -T git@github.com 2&> /dev/null
		[ $? -eq 255 ] && echo -e "$FAIL $HMC SSH KEY not found in github website" && return 1;
	    echo -e "$SUCCESS $HMC SSH Key found in github website"
	}
    # check commands
    for COMMAND in ${COMMANDS[@]}; do command -v $COMMAND 2&> /dev/null && echo -e "$SUCCESS $HMC Command \"$COMMAND\" Found" || { echo -e "$FAIL $HMC Command \"$COMMAND\" not found"; return 1; } done
	# check arguments
	[ $# -eq 0 ] && echo -e "$FAIL $HMC Argument empty" && return 1;
    [ $# -le 3 ] && echo -e "$FAIL $HMC Argument not enough" && return 1;
    ! [[ "$1" =~ $REGEX_USERNAME ]] && echo -e "$FAIL $HMC Invalid username" && return 1;
    ! [[ "$2" =~ $REGEX_EMAIL ]] && echo -e "$FAIL $HMC Invalid email" && return 1;
    ! [[ "$4" =~ $REGEX_REPO ]] && echo -e "$FAIL $HMC Invalid repository name" && return 1;

    read -p "$(printf $INFO) you want to sign commit? (y/n) : " IS_SIGN

	echo -e "$INFO verify infomation before next step" \
			"\n$INFO - username       : $1" \
			"\n$INFO - email          : $2" \
			"\n$INFO - branch         : $3" \
			"\n$INFO - repository     : $4" \
			"\n$INFO - commit message : ${5:-$DEFAULT_MSG}" \
			"\n$INFO - sign commit    : $([ "$IS_SIGN" == "y" ] && echo "yes" || echo "no")"
	read -p "$(printf $INFO) press enter key to continue"	
    sleep 1;
    # check ssh key user
    if ! [ -f "$SSH_KEY" ]; then
        # user private key not have
        eval "$(ssh-agent -s)" 2&> /dev/null
        ssh-keygen -t ed25519 -f "github_$1" -C "$2"
        ssh-add $SSH_KEY 2&> /dev/null
        mv "github_$1" "github_$1".pub "$SSH_DIR"
        openWebsite || return 1;
    else
        # user private key have already
        eval "$(ssh-agent -s)" 2&> /dev/null
        ssh-add $SSH_KEY 2&> /dev/null
        ssh -T git@github.com 2&> /dev/null
        [ $? -eq 255 ] && openWebsite && [ $? -eq 1 ] && return 1;
    fi
    sleep 2;
    # start git upload
    ! [ -f .git/config ] && {
    	git init > /dev/null 2>&1
    	git branch -M "$3"
    	git remote add origin "git@github.com:$1/$4.git"
	} || {
		git checkout -b "$3" 2&> /dev/null || git switch "$3" 2&> /dev/null
	}
    git config --local user.name $1
    git config --local user.email $2
    git config --local core.editor "$IS_EDITOR"
    git add .
    # sign commit
    #
    # wait move to function
    #
    #
    [[ $IS_SIGN == "y" ]] && {
        ! [ `git config --local user.signingkey` ] && {
    	read -p "$(printf $INFO) enter your sign keyID : " SIGN_KEY
        git config --local user.signingkey $SIGN_KEY
    	git commit -S -m "${5:-$DEFAULT_MSG}" || {
            echo -e "$FAIL $HMC Commit Failed"
            gpg --list-secret-keys --keyid-format LONG
            read -p "$(printf $INFO) enter your sign keyID : " SIGN_KEY
            git config --local user.signingkey $SIGN_KEY
            git commit -S -m "${5:-$DEFAULT_MSG}" || echo -e "$FAIL $HMC Commit Failed" || return 1;
        }
        } || {
            git commit -S -m "${5:-$DEFAULT_MSG}" || {
                echo -e "$FAIL $HMC Commit Failed"
                gpg --list-secret-keys --keyid-format LONG
                read -p "$(printf $INFO) enter your sign keyID : " SIGN_KEY
                git config --local user.signingkey $SIGN_KEY
                git commit -S -m "${5:-$DEFAULT_MSG}" || echo -e "$FAIL $HMC Commit Failed" || return 1;
            }
        }
    }
    [[ $IS_SIGN == "n" ]] && {
        git commit -m "${5:-$DEFAULT_MSG}"
    }
    echo -e "$SUCCESS $HMC Save progress on branch \"$3\""
    read -p "$(printf $INFO) press enter key for upload to github"
    git push --set-upstream origin "$3" || {
    	echo -e "$INFO branch $3 has been already in github"
    	read -p	"you want history commit preserved? (y/n) : " IS_PRRSERVED
    	[[ $IS_PRRSERVED == "n" ]] && {
    		echo -e "$INFO ${ALERT}history commit will be disappear\e[0m"
    		read -p "$(printf $INFO) press enter key to force upload"
    		git push -f --set-upstream origin "$3" || echo -e "$FAIL $HMC Upload Failed"
    	}
    	[[ $IS_PRRSERVED == "y" ]] && {
    		git pull origin "$3" --rebase
    		local -a CONFLICT_FILES=($(git diff --name-only | uniq))
    		echo -e "$INFO This is all conflict files :" \
    				"\n$INFO ${CONFLICT_FILES[@]}" \
    				"\n$INFO - choice between you or friend code" \
    				"\n$INFO - delete unwanted code" \
    				"\n$INFO - save file and quit"
    		read -p "$(printf $INFO) press enter key to continue"
    		$IS_EDITOR ${CONFLICT_FILES[@]}
    		git add .
    		git rebase --continue
    		git push --set-upstream origin "$3" || {
    			echo -e "$FAIL $HMC Upload Failed"
    			return 1;
    		}
    	}
    }
    echo -e "$SUCCESS $HMC Upload Successfully"
}
