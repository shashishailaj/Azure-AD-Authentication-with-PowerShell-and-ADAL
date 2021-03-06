# Load ADAL
Add-Type -Path ".\ADAL\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

# Output Token and Response from AAD Graph API
$accessToken = ".\Token.txt"
$output = ".\Output.json"

# Application and Tenant Configuration
$clientId = "<AppIDGUID>"
$tenantId = "<TenantID>"
$resourceId = "https://graph.windows.net"
$login = "https://login.microsoftonline.com"

# Create Client Credential Using App Key
$secret = "<AppKey>"

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

# Output response as a JSON file
Invoke-RestMethod -Method Get -Uri ("{0}/{1}/users?api-version=1.6" -f $resourceId,$tenantId)  -Headers $headers -OutFile $output