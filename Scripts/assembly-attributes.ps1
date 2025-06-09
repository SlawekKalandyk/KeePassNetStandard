function Get-AssemblyAttributes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$assemblyInfoPath
    )

    if (-not (Test-Path $assemblyInfoPath)) {
        throw "AssemblyInfo.cs not found: $assemblyInfoPath"
    }

    $assemblyInfo = Get-Content $assemblyInfoPath

    $attrs = @{}
    $attrs.Id = Get-AssemblyAttribute "AssemblyTitle" $assemblyInfo
    $attrs.Version = Get-AssemblyAttribute "AssemblyVersion" $assemblyInfo
    if ($attrs.Version -match "\.\*$") {
        $attrs.Version = $attrs.Version -replace "\.\*$", ""
    }
    $attrs.Description = Get-AssemblyAttribute "AssemblyDescription" $assemblyInfo
    $attrs.Company = Get-AssemblyAttribute "AssemblyCompany" $assemblyInfo
    $attrs.Product = Get-AssemblyAttribute "AssemblyProduct" $assemblyInfo
    $attrs.Authors = $attrs.Company
    if (-not $attrs.Authors) { $attrs.Authors = "Unknown" }
    $attrs.Copyright = Get-AssemblyAttribute "AssemblyCopyright" $assemblyInfo
    return $attrs
}

function Get-AssemblyAttribute($name, $assemblyInfo) {
    $pattern = "\[assembly:\s*$name\(""([^""]*)""\)\]"
    $match = $assemblyInfo -match $pattern
    if ($match) {
        return ($assemblyInfo | Select-String -Pattern $pattern).Matches[0].Groups[1].Value
    }
    return ""
}
