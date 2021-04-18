<# 
.SYNOPSIS 
 
 
.DESCRIPTION 
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-02-03
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Certificate generation for SMTP
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#>

#Create Cert
$servercert=New-SelfSignedCertificate  `
 -CertStoreLocation cert:/LocalMachine/My `
 -DnsName "ADNSDALHa1M012.pr.dir"  `
 -NotAfter (Get-Date).AddYears(3) `
 -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") `
 -KeyFriendlyName "ADNSDALHa1M012.pr.dir" `
 -KeyDescription "Used for LDAPS & SMTP-TLS" `
 -FriendlyName "ADNSDALHa1M012.pr.dir" 

#Grab Thumbprint
$thumbprint=($servercert.Thumbprint | Out-String).Trim()

#Copy to Certstores
#Local Machine - Trusted Root Certificate Authorities
Copy-Item `
 -Path HKLM:/Software/Microsoft/SystemCertificates/My/Certificates/$thumbprint `
 -Destination 'HKLM:/Software/Microsoft/SystemCertificates/Root/Certificates'
 
#Active Directory - Trusted Root Certificate Authorities
Copy-Item `
 -Path HKLM:/Software/Microsoft/SystemCertificates/My/Certificates/$thumbprint `
 -Destination 'HKLM:/Software/Microsoft/Cryptography/Services/NTDS/SystemCertificates/Root/Certificates'

#SMTP - Trusted Root Certificate Authorities
Copy-Item `
 -Path HKLM:/Software/Microsoft/SystemCertificates/My/Certificates/$thumbprint `
 -Destination 'HKLM:/Software/Microsoft/Cryptography/Services/SMTPSVC/SystemCertificates/Root/Certificates'

#TODO
#Grab thumbprint of existing cert
#Purge from other locations?  or are they linked? 
