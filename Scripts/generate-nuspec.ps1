param (
    [Parameter(Mandatory = $true)]
    [string[]]$csprojPaths,
    [Parameter(Mandatory = $true)]
    [string]$assemblyInfoPath,
    [string]$outputPath = ""
)

if (-not (Test-Path $assemblyInfoPath)) {
    Write-Error "AssemblyInfo.cs not found: $assemblyInfoPath"
    exit 1
}

. (Join-Path $PSScriptRoot 'assembly-attributes.ps1')

$attrs = Get-AssemblyAttributes -assemblyInfoPath $assemblyInfoPath
$id = $attrs.Id
$version = $attrs.Version
$description = $attrs.Description
$company = $attrs.Company
$product = $attrs.Product
$authors = $attrs.Authors
$copyright = $attrs.Copyright

# Collect and deduplicate dependencies
$depDict = @{}

foreach ($csprojPath in $csprojPaths) {
    if (-not (Test-Path $csprojPath)) {
        Write-Warning "Project file not found: $csprojPath"
        continue
    }
    [xml]$projXml = Get-Content $csprojPath
    $projXml.Project.ItemGroup.PackageReference | ForEach-Object {
        $depId = $_.Include
        $depVersion = $_.Version
        if ($depId -and $depVersion) {
            if ($depDict.ContainsKey($depId)) {
                # Use the highest version
                if ([version]$depVersion -gt [version]$depDict[$depId]) {
                    $depDict[$depId] = $depVersion
                }
            } else {
                $depDict[$depId] = $depVersion
            }
        }
    }
}

$dependencies = $depDict.GetEnumerator() | Sort-Object Name | ForEach-Object {
    "      <dependency id=""$($_.Key)"" version=""$($_.Value)"" />"
}

# Compose nuspec content
$nuspec = @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
  <metadata>
    <id>$id</id>
    <version>$version</version>
    <authors>$authors</authors>
    <description>$description</description>
    <copyright>$copyright</copyright>
    <dependencies>
$($dependencies -join "`n")
    </dependencies>
  </metadata>
  <files>
    <file src="bin\Release\*.dll" target="lib\netstandard2.0" />
  </files>
</package>
"@

if (-not $outputPath) {
    $outputPath = Join-Path (Split-Path $csprojPaths[0]) "$id.nuspec"
}
$nuspec | Set-Content $outputPath -Encoding UTF8

Write-Host "Generated $outputPath"