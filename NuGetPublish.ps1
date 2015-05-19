param (
    [parameter(Mandatory=$true)]
    [alias("p")]
    [string]$ProjectFile,
    [parameter(Mandatory=$true)]
    [alias("n")]
    [string]$ProjectName,
    [alias("s")]
    [string]$NugetSource = "https://www.nuget.org/api/v2/",
    [alias("k")]
    [string]$ApiKey = "",
    [alias("c")]
    [string]$BuildConfiguration = "Release"
)

##############
#Get the old version and increment it
##############
#get our packages

$packages = nuget list -Verbosity detailed -Source $NugetSource

$counter=0

#snag out the version of the project that we are currently on
DO {$counter++} Until ($packages[$counter] -eq $ProjectName)
$version = $packages[$counter+1]

#increment that version
$splitVersion = $version.split(".")
$incrementedVersion = [string] (1+$splitVersion[-1])
$splitVersion[-1] = $incrementedVersion
$joinedVersion = [string]::join(".", $splitVersion)


nuget pack $ProjectFile -IncludeReferencedProjects -Properties Configuration=$BuildConfiguration -Version $joinedVersion




# pack and push
nuget pack $ProjectFile -IncludeReferencedProjects -Properties Configuration=$BuildConfiguration -Build -Symbols
nuget setApiKey -Source $NugetSource $ApiKey
nuget push $ProjectName + ".*.nupkg" -s $NugetSource
cp .\WiserAir.Common.*.nupkg .\builds -Force
rm .\WiserAir.Common.*.nupkg