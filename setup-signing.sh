#!/bin/bash
set -e

CERT_NAME="KeyboardClean Dev"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-identity -v -p codesigning "$KEYCHAIN" | grep -q "$CERT_NAME"; then
    echo "Codesigning identity '$CERT_NAME' already present. Nothing to do."
    exit 0
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

KEY="$WORK/key.pem"
CRT="$WORK/cert.pem"

openssl req -x509 -newkey rsa:2048 -keyout "$KEY" -out "$CRT" \
    -days 3650 -nodes \
    -subj "/CN=$CERT_NAME" \
    -addext "basicConstraints=critical,CA:false" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning" 2>/dev/null

security import "$KEY" -k "$KEYCHAIN" -t priv -A >/dev/null
security import "$CRT" -k "$KEYCHAIN" -t cert -A >/dev/null
security add-trusted-cert -p codeSign -k "$KEYCHAIN" "$CRT"

echo
echo "Created codesigning identity '$CERT_NAME'."
security find-identity -v -p codesigning "$KEYCHAIN" | grep "$CERT_NAME"
echo
echo "Now run ./build.sh — first sign may prompt for keychain access; click 'Always Allow'."
