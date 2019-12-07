: # This is a special script which intermixes both sh
: # and cmd code. It is written this way because it is
: # used in system() shell-outs directly in otherwise
: # portable code. See https://stackoverflow.com/questions/17510688
: # for details.
:; echo "This is ${SHELL}"; exit
@ECHO OFF
vagrant ssh -c  "cd /vagrant && /usr/local/bin/composer %*"
