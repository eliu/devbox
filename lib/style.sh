STYLE_GREEN="\e[32m"
STYLE_YELLOW="\e[33m"
STYLE_RED="\e[91m"
STYLE_CYAN="\e[36m"
STYLE_RESET="\e[39m"

style::green() { echo -e "$STYLE_GREEN$@$STYLE_RESET"
}
style::yellow() { echo -e "$STYLE_YELLOW$@$STYLE_RESET"
}
style::red() { echo -e "$STYLE_RED$@$STYLE_RESET"
}
style::cyan() { echo -e "$STYLE_CYAN$@$STYLE_RESET"
}