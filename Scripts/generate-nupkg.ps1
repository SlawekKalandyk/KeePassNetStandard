$baseDir = Split-Path $PSScriptRoot -Parent
$csprojPaths = @(
    (Join-Path $baseDir 'KeePassLib\KeePassLib.csproj'),
    (Join-Path $baseDir 'KeePassNetStandard\KeePassNetStandard.csproj')
)
$assemblyInfoPath = Join-Path $baseDir 'KeePassLib\Properties\AssemblyInfo.cs'
$outputPath = Join-Path $baseDir 'KeePassNetStandard.nuspec'

$nuspecScript = Join-Path $PSScriptRoot 'generate-nuspec.ps1'
$buildPropsScript = Join-Path $PSScriptRoot 'generate-build-props.ps1'

if (-not (Test-Path $nuspecScript)) {
    Write-Error "generate-nuspec.ps1 not found in $PSScriptRoot"
    exit 1
}

if (-not (Test-Path $buildPropsScript)) {
    Write-Error "generate-build-props.ps1 not found in $PSScriptRoot"
    exit 1
}

& $buildPropsScript

# Build both projects in Release mode
foreach ($csproj in $csprojPaths) {
    Write-Host "Building $csproj in Release mode..."
    dotnet build $csproj -c Release
}

# Generate nuspec
& $nuspecScript -csprojPaths $csprojPaths -assemblyInfoPath $assemblyInfoPath -outputPath $outputPath

Write-Host "Nuspec file generated via generate-nuspec.ps1."

# Generate nupkg
$packageOutputDir = Join-Path $baseDir 'bin\Release'
Write-Host "Packing nupkg using $outputPath..."
nuget pack $outputPath -OutputDirectory $packageOutputDir
Write-Host "nupkg file generated in $packageOutputDir."