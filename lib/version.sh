# ----------------------------------------------------------------
# Print os info
# ----------------------------------------------------------------
version::os() {
  cat /etc/system-release
}

# ----------------------------------------------------------------
# Print currently installed EPEL repo version
# ----------------------------------------------------------------
version::epel(){
  dnf list installed "epel*" 2>/dev/null | grep epel | awk '{print $1"."$2}'
}

# ----------------------------------------------------------------
# Print currently installed java version
# ----------------------------------------------------------------
version::java() {
  has_command java && java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'
}

# ----------------------------------------------------------------
# Print currently installed maven version
# ----------------------------------------------------------------
version::maven() {
  has_command java && has_command mvn && mvn -version | head -n 1 | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed git version
# ----------------------------------------------------------------
version::git() {
  has_command git && git version | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed python3 version
# ----------------------------------------------------------------
version::python3() {
  has_command python3 && python3 -V | cut -d' ' -f2
}

# ----------------------------------------------------------------
# Print currently installed pip3 version
# ----------------------------------------------------------------
version::pip3() {
  has_command pip3 && pip3 -V | cut -d' ' -f2
}

# ----------------------------------------------------------------
# Print version of the component commonly using form `command -v`
# ----------------------------------------------------------------
version::of() {
  has_command $1 && $1 -v
}