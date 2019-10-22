<#

.SYNOPSIS
    Given a previously downloaded PVWA Config XML file, attempts to parse it, and generate a report of PSM servers assigned to each platform

.DESCRIPTION
    If you supply the downloaded XLM filese from the PVWAConfig safe, you'll be able to generate a fancy CSV file showing PSM assigned to each platform.

.OUTPUTS
    Console verbose output during run and a fancy CSV from the 80's with the reporting data

.EXAMPLE
    PS C:\> .\Get-PSMPerPlatform.ps1
    Runs the script

.NOTES
    NAME: Get-PSMPerPlatform.ps1
    AUTHOR: https://github.com/mhdevop
    LASTEDIT: 10/22/2019
    Requires -Version 4.0
#>

############################################################################  CHANGE ME !!!!! (put in your own variable data) ###########################################################################
$pathToPoliciesXMLFile = "C:\Users\you\CyberArk\Policies.xml" #TODO - automate PACLI downloading this file for you instead of manually getting it from PrivateArk. (short on time today)
$pathToCSVReport = "C:\Users\you\CyberArk\PSMPerPolicyReport.csv"

############################################################################  MAIN  - Don't edit anything in here unless you know what you're doing #####################################################

#attempt to read the XML file you provided and cast it to an XML document
[xml]$xmlpvwa = get-content $pathToPoliciesXMLFile

#my poor attempt to use XLM XPath to filter the massive document and extract each XML node (there's probably a cleaner/better way of doing this).
$node = $null
$node = $xmlpvwa.PasswordVaultPolicies | Select-Xml -XPath "//Policy" | select -ExpandProperty node

#you can comment this if you don't like it. Makes you feel good to see how many policies you have though
Write-Output "You have $($node.Count) total policies!"

#instantiate empty array to populate later - probably better way of doing this too
$masterPlatform = @()

#loop through each XML node document
foreach($n in $node)
{
    #create empty object
    $obj = new-object psobject

    #create attributes and populate them with the parsed XML data. I'm old school so I like old-fashioned 2-dimensional arrays
    $obj | Add-Member -MemberType NoteProperty -Name "PlatformID" -Value "$($n.ID)" -Force
    $obj | Add-Member -MemberType NoteProperty -Name "PSMID" -Value "$($n.PrivilegedSessionManagement.ID)" -Force   
    
    #dump our temporary object in to the array for safe keeping as it will get overwridden on the next iteration
    $masterPlatform += $obj
}

#I like to know right away if it worked or not so show a GUI of the report and also dump to an old school CSV file
$masterPlatform | Out-GridView -Title 'PSM Server Per Platform'
$masterPlatform | Export-Csv $pathToCSVReport -NoTypeInformation -force
