# Load ADAL
Add-Type -Path ".\ADAL\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

# Load our Login Browser Function
Import-Module ./LoginBrowser.psm1

# Output Token and Response from AAD Graph API
$accessToken = ".\Token.txt"
$output = ".\Output.json"

# Application and Tenant Configuration
$clientId = "<AppIDGUID>"
$tenantId = "<TenantID>"
$resourceId = "https://graph.windows.net"
$redirectUri = New-Object system.uri("<ReplyURL>")
$login = "https://login.microsoftonline.com"

# Create Client Credential Using App Key
$secret = "<AppKey>"

# Create Client Credential Using Certificate
#$certFile = "<PFXFilePath>"
#$certFilePassword = "<CertPassword>"
#$secret = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList $certFile,$certFilePassword

# Note you can adjust the querystring paramters here to change things like prompting for consent
$authorzationUrl = ("{0}/{1}/oauth2/authorize?response_type=code&client_id={2}&redirect_uri={3}&resource={4}&prompt=consent" -f $login,$tenantId,$clientId,$redirectUri,$resourceId)
# Fake a proper endpoint for the Redirect URI
$code = LoginBrowser $authorzationUrl $redirectUri

# Get an Access Token with ADAL
$clientCredential = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential($clientId,$secret)
$authContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext("{0}/{1}" -f $login,$tenantId)
$authenticationResult = $authContext.AcquireToken($resourceId, $clientcredential)
($token = $authenticationResult.AccessToken) | Out-File $accessToken


# Call the AAD Graph API 
$headers = @{ 
    "Authorization" = ("Bearer {0}" -f $token);
    "Content-Type" = "application/json";
}

# Output response as JSON file
Invoke-RestMethod -Method Get -Uri ("{0}/{1}/users?api-version=1.6" -f $resourceId,$tenantId)  -Headers $headers -OutFile $output