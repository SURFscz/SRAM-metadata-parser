#!/usr/bin/env python
import sys
import yaml
from lxml import etree

nsmap = {
    'xml': 'http://www.w3.org/XML/1998/namespace',
    'saml': 'urn:oasis:names:tc:SAML:2.0:assertion',
    'md': 'urn:oasis:names:tc:SAML:2.0:metadata',
    'ds': 'http://www.w3.org/2000/09/xmldsig#',
    'mdrpi': 'urn:oasis:names:tc:SAML:metadata:rpi',
    'mdattr': 'urn:oasis:names:tc:SAML:metadata:attribute'
}

entityIDs = []


def parse_file(f, data, select):
    print(f)
    tree = etree.parse(f).getroot()
    tag = etree.QName(tree).localname
    entities = []
    if tag == "EntitiesDescriptor":
        entities = tree.iterfind('md:EntityDescriptor', tree.nsmap)
    elif tag == "EntityDescriptor":
        entities = [tree]
    for result in entities:
        entityID = result.get("entityID")
        print(f"  {entityID}", end='')
        if not select or entityID in select:
            if entityID not in entityIDs:
                print(" [a]")  # Append
                entityIDs.append(entityID)
                data.insert(len(data), result)
            else:
                print(" [s]")  # Skipped
        else:
            print(" [o]")      # Out


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(sys.argv[0] + "  <config.yml> <output>")

    with open(sys.argv[1]) as f:
        config = yaml.safe_load(f)

    data = etree.Element("{urn:oasis:names:tc:SAML:2.0:metadata}EntitiesDescriptor", nsmap=nsmap)

    for f in config.get('in', []):
        parse_file(f, data, config.get('select', []))

with open(sys.argv[2], "w") as output:
    output.write(etree.tostring(data, pretty_print=True).decode('utf-8'))
