﻿<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
                xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
                version="2.0">

    <!-- Cleanup -->
    <xsl:template match="@ID"/>
    <xsl:template match="@Id"/>
    <xsl:template match="@xml:id"/>
    <xsl:template match="@validUntil"/>
    <xsl:template match="@cacheDuration"/>
    <xsl:template match="@xml:base"/>
    <xsl:template match="ds:Signature"/>
    <xsl:template match="md:Extensions/mdattr:EntityAttributes"/>

    <!-- Identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add ContactPerson -->
    <xsl:template match="md:EntityDescriptor">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
          <md:ContactPerson xmlns:remd="http://refeds.org/metadata" contactType="other" remd:contactType="http://refeds.org/metadata/contactType/security">
            <md:GivenName>Security Response Team</md:GivenName>
            <md:EmailAddress>mailto:securityincident@surf.nl</md:EmailAddress>
          </md:ContactPerson>
      </xsl:copy>
    </xsl:template>

    <!-- Add RegistrationInfo and sirtfi EntityAttributes -->
    <xsl:template match="md:IDPSSODescriptor/md:Extensions|md:SPSSODescriptor/md:Extensions">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
           <mdattr:EntityAttributes>
             <saml:Attribute NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" Name="urn:oasis:names:tc:SAML:attribute:assurance-certification">
               <saml:AttributeValue>https://refeds.org/sirtfi2</saml:AttributeValue>
               <saml:AttributeValue>https://refeds.org/sirtfi</saml:AttributeValue>
             </saml:Attribute>
           </mdattr:EntityAttributes>
      </xsl:copy>
    </xsl:template>

    <!-- Identity transform -->
    <xsl:template match="/md:EntitiesDescriptor">
        <xsl:copy>
          <xsl:attribute name="xml:id">metadata</xsl:attribute>
          <ds:Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
          <ds:SignedInfo>
           <ds:CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
            <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
             <ds:Reference URI="#metadata">
              <ds:Transforms>
               <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
              </ds:Transforms>
               <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                <ds:DigestValue></ds:DigestValue>
             </ds:Reference>
          </ds:SignedInfo>
          <ds:SignatureValue />
          <ds:KeyInfo>
           <ds:KeyValue />
          </ds:KeyInfo>
         </ds:Signature>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
