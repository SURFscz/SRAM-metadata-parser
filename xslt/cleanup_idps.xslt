<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
                xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                version="2.0">
    <!-- Cleanup -->
    <xsl:template match="@ID"/>
    <xsl:template match="@Id"/>
    <xsl:template match="@xml:id"/>
    <xsl:template match="@validUntil"/>
    <xsl:template match="@cacheDuration"/>
    <xsl:template match="@xml:base"/>
    <xsl:template match="ds:Signature"/>
    <xsl:template match="md:Extensions/mdrpi:RegistrationInfo"/>

    <!-- Identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Remove all SPSSODescriptor -->
    <xsl:template match="md:SPSSODescriptor"/>

    <!-- add <md:Extensions> if not present -->
    <xsl:template match="md:EntityDescriptor[not(md:Extensions)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <md:Extensions>
                <mdrpi:RegistrationInfo xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi" registrationAuthority="http://test.sram.surf.nl/"/>
            </md:Extensions>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- add Registrationinfo to the existing md:Extensions element directly under the EntityDescriptor -->
    <xsl:template match="md:EntityDescriptor/md:Extensions">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <mdrpi:RegistrationInfo xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi" registrationAuthority="http://test.sram.surf.nl/"/>
            <xsl:apply-templates/>
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
