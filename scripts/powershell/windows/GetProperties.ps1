#Ref: https://stackoverflow.com/questions/14970079/how-to-recursively-enumerate-through-properties-of-object
# Added the values not just the properties
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

# We don't care about the sub-properties of the following types:
$typesToExclude = "System.Boolean", "System.String", "System.Int32", "System.Char"
# Control how to print object values
$simpleTypesToPrint = "System.Boolean", "System.String", "System.Int32"
$charTypePrint = "System.Char"
$xmlTypePrint = "System.Xml.XmlElement"

# Add all properties from this level to the array.
$rootProps | ForEach-Object { 

    #Base name of property
    $propName = $_.Name;

    #Object to process
    $obj = $($Object.$propName)

    # Get the type, and only recurse into it if it is not one of our excluded types
    $type = ($obj.GetType()).ToString()

    if (($simpleTypesToPrint.Contains($type) ) ) {
            $props += "$PathName.$($_.Name)[$($Object.($_.Name))]"
    } elsif (($charTypePrint.Contains($type) ) ) {
            $temp = [String]::new($($Object.($_.Name)))
            $props += "$PathName.$($_.Name)[$temp]"
    } elsif (($xmlTypePrint.Contains($type) ) ) {
            $temp = [Xml.XmlElement]::new($($Object.($_.Name)))
            $props += "$PathName.$($_.Name)[$temp.Outer]"
    } else {    
            $props += "$PathName.$($_.Name)[$type]"
    }
}

# Make sure we're not exceeding the MaxLevels
if ($Level -lt $MaxLevels) {

    
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
            if ($null -ne $obj) {
                Get-Properties -Object $obj -PathName $childPathName -Level ($Level + 1) -MaxLevels $MaxLevels 
            }

        }
        else {
            $name = $propName
            $value = $($obj.($_.Name))
            $propName = "{0}[{1}]" -f $name,$value
        }
    }
}

if ($Level -eq 0) { $ErrorActionPreference = $oldErrorPreference }
$props
} 
