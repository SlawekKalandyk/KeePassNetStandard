$propsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Directory.Build.props'
$assemblyInfoPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'KeePassLib\Properties\AssemblyInfo.cs'

if (-not (Test-Path $assemblyInfoPath)) {
    Write-Error "AssemblyInfo.cs not found: $assemblyInfoPath"
    exit 1
}

. (Join-Path $PSScriptRoot 'assembly-attributes.ps1')

$attrs = Get-AssemblyAttributes -assemblyInfoPath $assemblyInfoPath
$version = $attrs.Version
$description = $attrs.Description
$company = $attrs.Company
$product = $attrs.Product
$authors = $attrs.Authors
$copyright = $attrs.Copyright

$xml = @"
<Project>
  <PropertyGroup>
    <Version>$version</Version>
    <Description>$description</Description>
    <Company>$company</Company>
    <Product>$product</Product>
    <Authors>$authors</Authors>
    <Copyright>$copyright</Copyright>
  </PropertyGroup>
</Project>
"@

$xml | Set-Content $propsPath -Encoding UTF8
Write-Host "Generated $propsPath"