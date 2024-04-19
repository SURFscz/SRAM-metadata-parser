#!/bin/sh
set -e

# Create temporary directories
mkdir -p out
mkdir -p tmp

if [ ! -f cert/signing.key ]; then
    openssl req -x509 -newkey rsa:4096 -keyout cert/signing.key -out cert/signing.pem -sha256 -days 365 -nodes -subj "/CN=Signing"
fi

./pyff-lite.py config/test.yml tmp/test_parsed.xml
xalan -in tmp/test_parsed.xml -xsl xslt/cleanup_test.xslt > tmp/test_parsed_clean.xml
xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output out/test_signed.xml tmp/test_parsed_clean.xml
xmlsec1 verify --pubkey-cert-pem cert/signing.pem out/test_signed.xml

# IDP's
wget https://metadata.test.surfconext.nl/idps-metadata.xml -O tmp/idps-metadata.xml
xmlsec1 verify --pubkey-cert-pem cert/surfconext.crt --id-attr:ID EntitiesDescriptor  tmp/idps-metadata.xml
./pyff-lite.py config/idps.yml tmp/idps-metadata_parsed.xml
xalan -in tmp/idps-metadata_parsed.xml -xsl xslt/cleanup_idps.xslt > tmp/idps-metadata_parsed_clean.xml
xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output out/idps-metadata_signed.xml tmp/idps-metadata_parsed_clean.xml
xmlsec1 verify --pubkey-cert-pem cert/signing.pem out/idps-metadata_signed.xml

# Backend
wget https://proxy.acc.sram.eduteams.org/metadata/backend.xml -O tmp/backend.xml
# xmlsec1 verify --pubkey-cert-pem cert/backend.crt tmp/backend.xml
./pyff-lite.py config/backend.yml tmp/backend_parsed.xml
xalan -in tmp/backend_parsed.xml -xsl xslt/cleanup_proxy.xslt > tmp/backend_parsed_clean.xml
xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output out/backend_signed.xml tmp/backend_parsed_clean.xml
xmlsec1 verify --pubkey-cert-pem cert/signing.pem out/backend_signed.xml

# Frontend
wget https://proxy.acc.sram.eduteams.org/metadata/frontend.xml -O tmp/frontend.xml
# xmlsec1 verify --pubkey-cert-pem cert/frontend.crt tmp/frontend.xml
./pyff-lite.py config/frontend.yml tmp/frontend_parsed.xml
xalan -in tmp/frontend_parsed.xml -xsl xslt/cleanup_proxy.xslt > tmp/frontend_parsed_clean.xml
xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output out/frontend_signed.xml tmp/frontend_parsed_clean.xml
xmlsec1 verify --pubkey-cert-pem cert/signing.pem out/frontend_signed.xml

# Edugain
if [ ! -f tmp/edugain.xml ]; then
     wget https://mds.edugain.org/edugain-v2.xml -O tmp/edugain.xml
fi
xmlsec1 verify --pubkey-cert-pem cert/mds-v2.cer --id-attr:ID EntitiesDescriptor tmp/edugain.xml
./pyff-lite.py config/edugain.yml tmp/edugain_parsed.xml
xalan -in tmp/edugain_parsed.xml -xsl xslt/cleanup_edugain.xslt > tmp/edugain_parsed_clean.xml
xmlsec1 sign --pubkey-cert-pem cert/signing.pem --privkey-pem cert/signing.key --output out/edugain_signed.xml tmp/edugain_parsed_clean.xml
xmlsec1 verify --pubkey-cert-pem cert/signing.pem out/edugain_signed.xml

