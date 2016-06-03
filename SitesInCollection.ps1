#Specify tenant admin and site URL
$adminUrl = "https://devjam-admin.sharepoint.com/"
$siteUrl = "https://devjam.sharepoint.com/"

#Use Credential Manager module
#Install-Module -Name CredentialManager
if ((Get-Module CredentialManager).Count -eq 0) 
{
    #Write-Host "module doesnt exist"
    Import-Module CredentialManager -DisableNameChecking
}
#else{
#Write-Host "module exists"
#}

#retrieve Stored Credentials
$storedCredential = Get-StoredCredential -Target "SPOdemo"
$spoCredential = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($storedCredential.UserName, $storedCredential.Password) 

#Add references to SharePoint client assemblies for CSOM
$csomPath = "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\"
Add-Type –Path ($csomPath + "Microsoft.SharePoint.Client.dll") 
Add-Type –Path ($csomPath + "Microsoft.SharePoint.Client.Runtime.dll")

#authenticate to SharePoint Online
Connect-SPOService -Url $adminUrl -Credential $storedCredential

#Function to get all sites inside the site Url
function Get-SPOWebs(){
    
   param(
    [Parameter(Mandatory)]
    [ValidatePattern('^https?:\/\/')]
    [string]
    $url = $(throw "Please provide a Site Collection Url"),

    [Parameter(Mandatory)]
    $credential = $(throw "Please provide a Credentials")
   )

  $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($url)  
  $ctx.Credentials = $credential
  
  $web = $ctx.Web
  $ctx.Load($web)
  $ctx.Load($web.Webs)
  $ctx.ExecuteQuery()
  foreach($web in $web.Webs)
  {
       Get-SPOWebs -Url $web.Url -Credential $credential 
       $web
  }
}

#Get all site collection
$sites = Get-SPOSite 

#Retrieve and output all sites in each site collection
foreach ($site in $sites)
{
    Write-Host 'Site collection:' $site.Url     
    $AllWebs = Get-SPOWebs -Url $site.Url -Credential $spoCredential
    $AllWebs | %{ Write-Host $_.Title }   
    Write-Host '-----------------------------' 
}    


#Retrieve all site in a given Site Collection
$AllWebs = Get-SPOWebs -Url $siteUrl -Credential $spoCredential
Write-Host '-----------------------------' 
$AllWebs | %{ Write-Host $_.Title }  
Write-Host '-----------------------------' 


##Formatting string in powershell
#Write-host  ("{0} * {1} * {2}" -f $var1,$var2,$var3 )