require vagrant
require logging
require config
require setup
require components/openjdk

readonly M2_TEMPDIR="$(mktemp -d)"
readonly M2_MAJOR="3"
readonly M2_VERSION="3.9.12"
readonly M2_MIRROR="https://mirrors.aliyun.com/apache/maven"
readonly M2_URL="$M2_MIRROR/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"


# ----------------------------------------------------------------
# Install Maven
# Scope: private
# ----------------------------------------------------------------
maven::installer() {
  config::get installer.maven.enabled && {
    openjdk::install
    maven::install
  } || maven::uninstall
}

maven::accelerate() {
  grep aliyun $VAGRANT_HOME/.m2/settings.xml > /dev/null 2>&1 || {
    log::info "Accelerating maven repo..."
    mkdir -p $VAGRANT_HOME/.m2
    cp /vagrant/lib/components/maven/settings.xml $VAGRANT_HOME/.m2/settings.xml
    vg::chown $VAGRANT_HOME/.m2
  }
}

maven::install() {
  has_command mvn || {
    has_command java || log::fatal "You must install java platform first!"
    log::info "Installing maven..."
    log::verbose "Downloading maven from ${M2_URL}"
    log::verbose "Temp dir is ${M2_TEMPDIR}"
    curl -sSL ${M2_URL} -o "${M2_TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
    log::verbose "Extracting files to /opt..."
    tar zxf "${M2_TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
    maven::accelerate
    setup::add_context "MAVEN_HOME" "export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}"
    setup::add_context "PATH" "export PATH=\$MAVEN_HOME/bin:\$PATH"
  }
}

maven::uninstall() {
  has_command mvn && {
    setup::del_context "MAVEN_HOME"
    log::info "Uninstalling maven..."
    rm -fr /opt/apache-maven*
  } || true
}

# ----------------------------------------------------------------
# Print currently installed maven version
# ----------------------------------------------------------------
maven::version() {
  has_command java && has_command mvn && mvn -version | head -n 1 | awk '{print $3}'
}