<# 
.SYNOPSIS 
 Finds ESG and enabled BGP for GRE Tunnel
 
.DESCRIPTION 
 
.EXAMPLE
C:\tmp\ESG-BGP_GRE.ps1 -username "mwiles@st.dir" -password "REDACTED"
 
.PARAMETER username
   username for the vcsa
.PARAMETER password
   password for the vcsa username 

.LINK
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.cloud/commands/get-edgegateway/#Default
https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.cloud/structures/vmware.vimautomation.cloud.types.v1.edgegateway/
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-04-27
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Finds ESG and enabled BGP for GRE Tunnel
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>
param (
   [Parameter(Mandatory=$true)][string]$username,
   [Parameter(Mandatory=$true)][string]$password
)
 
# https://stackoverflow.com/questions/14970079/how-to-recursively-enumerate-through-properties-of-object
function Get-Properties($Object, $MaxLevels = "5", $PathName = "`$_", $Level = 0) {
    <#
        .SYNOPSIS
        Returns a list of all properties of the input object
        .DESCRIPTION
        Recursively 
        .PARAMETER Object
        Mandatory - The object to list properties of
        .PARAMETER MaxLevels
        Specifies how many levels deep to list
        .PARAMETER PathName
        Specifies the path name to use as the root. If not specified, all properties will start with "."
        .PARAMETER Level
        Specifies which level the function is currently processing. Should not be used manually.
        .EXAMPLE
        $v = Get-View -ViewType VirtualMachine -Filter @{"Name" = "MyVM"}
        Get-Properties $v | ? {$_ -match "Host"}
        .NOTES
            FunctionName : 
            Created by   : KevinD
            Date Coded   : 02/19/2013 12:54:52
        .LINK
            http://stackoverflow.com/users/1298933/kevind
     #>
    if ($Level -eq 0) { 
        $oldErrorPreference = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
    }

    #Initialize an array to store properties
    $props = @()
    # Get all properties of this level
    $rootProps = $Object | Get-Member -ErrorAction SilentlyContinue | Where-Object { $_.MemberType -match "Property" } 
    # Add all properties from this level to the array.
    $rootProps | ForEach-Object { $props += "$PathName.$($_.Name)" }
    # Make sure we're not exceeding the MaxLevels
    if ($Level -lt $MaxLevels) {
        # We don't care about the sub-properties of the following types:
        $typesToExclude = "System.Boolean", "System.String", "System.Int32", "System.Char"
        #Loop through the root properties
        $props += $rootProps | ForEach-Object {
            #Base name of property
            $propName = $_.Name;
            #Object to process
            $obj = $($Object.$propName)
            # Get the type, and only recurse into it if it is not one of our excluded types
            $type = ($obj.GetType()).ToString()
            # Only recurse if it's not of a type in our list
            if (!($typesToExclude.Contains($type) ) ) {
                #Path to property
                $childPathName = "$PathName.$propName"
                # Make sure it's not null, then recurse, incrementing $Level                        
                if ($obj -ne $null) {
                    Get-Properties -Object $obj -PathName $childPathName -Level ($Level + 1) -MaxLevels $MaxLevels 
                }
            }
            else {
                $propName += "[$obj.GetValue()}"
            }
        }
    }
    if ($Level -eq 0) { $ErrorActionPreference = $oldErrorPreference }
    $props
}
$esgname = "edge-name"
$vcsaName = "vcsa-name"

# connect to vcsa and scope down to the datacenter, cluster, recourcepool ...
$vcsa = Connect-VIServer -Server $vcsaName -User $username -Password $password
# create a connection to the NSX manager
$nsxManager = Connect-NsxServer -vCenterServer $vcsa -User $username -Password $password
# set the default
$DefaultNsxConnection = $nsxManager

# get all the ESG from the list of available ESGs
$nsxESG = Get-NsxEdge | Where-Object { $_.Name –match $esgname }
$nsxESG
Get-Properties -Object $nsxESG #| ? {$_ -match "Host" }

# clean up
Disconnect-NsxServer -Server $nsxManager -Confirm:$false 
Disconnect-VIServer -Server $vcsa -Confirm:$false