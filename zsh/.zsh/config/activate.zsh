# activate virtualenv with current directory
#
function activate() {
  # set virtualenv directory as current directory prefixed with py_
  BASENAME="py_${PWD##*/}"

  # initialize virtualenv dir if dir doesnt exist already
  if [ ! -d $BASENAME ]; then
    virtualenv $BASENAME
  fi

  # activate virtualenv
  source "$BASENAME/bin/activate"

  # source "$(find . -type d -name "pyenv_*")/bin/activate"
}
