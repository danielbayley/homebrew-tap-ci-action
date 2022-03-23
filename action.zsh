#! /bin/zsh --no-rcs --err-exit --pipe-fail --null-glob
source /etc/profile
#source <(brew shellenv)

#if (($+GITHUB_ACTIONS)) set $PWD #\*

if (($#)) then print -l **/$~^@:t:r.rb(D)
else git diff --staged --name-only --diff-filter ACM | grep '\.rb$'
fi | while read rb
do token=$GITHUB_REPOSITORY/$rb:t:r
   head -n 1 $rb | read first_line

  case $first_line in
    class*Formula)
      if ([[ $GITHUB_EVENT_NAME != pull_request ]]) &&
      brew test-bot --skip-setup --fail-fast --added-formulae $token --skip-recursive-dependents;;
      #--only-formulae #--testing-formulae

    cask*do)
      brew style $token #--display-cop-names
      #if egrep '^\s+appcast' $rb
      if ((!$+GITHUB_ACTIONS)) brew audit --cask --appcast $token #--skip-style #--new-cask

      brew audit --cask --strict ${GITHUB_ACTIONS+--online} $token ${@:2};; #--skip-style
      #--strict --git --online
      #--appcast
      #--token-conflicts
      #--display-cop-names

    *) brew style $rb
  esac
done
