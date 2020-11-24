export GOPATH="${GOPATH:-${PATH_GOLANG}}"

pre_install() {
    "${MAKE_SCRIPT_DIR}/config-files/go/go.sh" install ${VERBOSE}
}

install() {(
    set -e

    export GO111MODULE=on
    go get -v github.com/OWASP/Amass/v3/...

    mkdir -p "${PATH_AMASS}"
    echo '#!/bin/sh' >"${PATH_AMASS}/amass.sh"
    echo "${GOPATH}/bin/amass" '${@}' "-dir ${PATH_AMASS}" >>"${PATH_AMASS}/amass.sh"
    chmod +x "${PATH_AMASS}/amass.sh"
    ln -s "${PATH_AMASS}/amass.sh" /usr/bin/amass

    git clone "https://github.com/OWASP/Amass" "${MAKE_SCRIPT_DIR}/Amass"
    mkdir -p "${PATH_WORDLISTS}"
    cp -r "${MAKE_SCRIPT_DIR}/Amass/examples/wordlists/" "${PATH_AMASS_WORDLISTS}"
    rm -rf "${MAKE_SCRIPT_DIR}/Amass"
    exit 0
)}

post_install() {(
    set -e
    "${MAKE_SCRIPT_DIR}/amass/amass_config.sh" install --for-user "${USER}" ${VERBOSE}
    [ -n "${SUDO_USER}" ] && "${MAKE_SCRIPT_DIR}/amass/amass_config.sh" install --for-user "${SUDO_USER}" ${VERBOSE}
    exit 0
)}

uninstall() {(
    set -e
    rm -rf /usr/bin/amass
    rm -rf "${PATH_AMASS}"
    rm -rf "${PATH_AMASS_WORDLISTS}"
    rm -rf "${GOPATH}/bin/amass"
    exit 0
)}

post_uninstall() {(
    set -e
    "${MAKE_SCRIPT_DIR}/amass/amass_config.sh" uninstall --for-user "${USER}" ${VERBOSE}
    [ -n "${SUDO_USER}" ] && "${MAKE_SCRIPT_DIR}/amass/amass_config.sh" uninstall --for-user "${SUDO_USER}" ${VERBOSE}
    "${MAKE_SCRIPT_DIR}/config-files/go/go.sh" uninstall ${VERBOSE}
    exit 0
)}
