#Rebrandly API Key https://developers.rebrandly.com/docs/api-key-authentication
$APIKEY = "yourKEy"

#Configure Daterange to delete older Links
$TimeSpanMonth = 2

#Rebrandly API Header with API Key
$headers = @{
  "apikey" = "$APIKEY"
}

#Get all Links with Paging
$URL = "https://api.rebrandly.com/v1/links"
$AllLinks = @()
do {
  
  if ($AllLinks) {
    $Latest = $AllLinks | Select-object -last 1
    $URL = "https://api.rebrandly.com/v1/links?last=$($Latest.id)"
  }

  $Repsonse = Invoke-RestMethod -Method GET -Uri $URL -Headers $headers
  $AllLinks += $Repsonse

  
} while ($Repsonse.count -gt 0)

#Amount of Links
$AllLinks.count

#Get Links with Zero Clicks
$ZeroClickLinks = $AllLinks | Where-Object -Property clicks -Value 0 -eq
$ZeroClickLinks.count


#Get Zero links older than Timepsan
$Limit = Get-Date -Format O (Get-Date).AddMonths(-$TimeSpanMonth)
$OlderLinks = $ZeroClickLinks | Where-Object -Property createdAt -Value $Limit -lt

$OlderLinks.count



#Go through each Link and Delete
foreach ($O in $OlderLinks) {

  $URLdelete = "https://api.rebrandly.com/v1/links/$($o.id)"
  Invoke-RestMethod -Method DELETE -Uri $URLdelete -Headers $headers

}
