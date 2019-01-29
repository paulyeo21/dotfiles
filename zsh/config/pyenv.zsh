# Create new pyenv and activate
function pyenv() {
  virtualenv "$1" && source "$1/bin/activate"
}
