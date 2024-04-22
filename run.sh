#!/bin/sh
set -e
trap 'rm -f -- tmp/tmp.*' EXIT

# Create temporary directories
mkdir -p out
mkdir -p tmp

if [ ! -f cert/signing.key ]; then
    openssl req -x509 -newkey rsa:4096 -keyout cert/signing.key -out cert/signing.pem -sha256 -days 365 -nodes -subj "/CN=Signing"
fi

parse() {
    PARSED=$(mktemp --tmpdir=tmp/)
    CLEANED=$(mktemp --tmpdir=tmp/)
    SIGNED=out/${1}_signed.xml

    time -v ./venv/bin/python smp.py config/${1}.yml $PARSED
    xalan -in $PARSED -xsl xslt/${2} > $CLEANED
    xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output $SIGNED $CLEANED
    xmlsec1 verify --pubkey-cert-pem cert/signing.pem $SIGNED
    rm -f -- tmp/tmp.*
}

# Test
parse test cleanup_test.xslt

# IDP's
TMP=$(mktemp --tmpdir=tmp/)
wget https://metadata.test.surfconext.nl/idps-metadata.xml -O $TMP
xmlsec1 verify --pubkey-cert-pem cert/surfconext.crt --id-attr:ID EntitiesDescriptor $TMP
mv $TMP tmp/idps-metadata.xml
parse idps-metadata cleanup_idps.xslt

# Backend
TMP=$(mktemp --tmpdir=tmp/)
wget https://proxy.acc.sram.eduteams.org/metadata/backend.xml -O $TMP
# xmlsec1 verify --pubkey-cert-pem cert/backend.crt $TMP
mv $TMP tmp/backend.xml
parse backend cleanup_proxy.xslt

# Frontend
TMP=$(mktemp --tmpdir=tmp/)
wget https://proxy.acc.sram.eduteams.org/metadata/frontend.xml -O $TMP
# xmlsec1 verify --pubkey-cert-pem cert/frontend.crt $TMP
mv $TMP tmp/frontend.xml
parse frontend cleanup_proxy.xslt

# Edugain
if [ ! -f tmp/edugain.xml ]; then
    TMP=$(mktemp --tmpdir=tmp/)
    wget https://mds.edugain.org/edugain-v2.xml -O $TMP
    xmlsec1 verify --pubkey-cert-pem cert/mds-v2.cer --id-attr:ID EntitiesDescriptor $TMP
    mv $TMP tmp/edugain.xml
fi
parse edugain cleanup_edugain.xslt
