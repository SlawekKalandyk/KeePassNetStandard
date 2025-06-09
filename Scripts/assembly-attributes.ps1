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
    $attrs.Id = Get-AssemblyAttr "AssemblyTitle"
    $attrs.Version = Get-AssemblyAttr "AssemblyVersion"
    if ($attrs.Version -match "\.\*$") {
        $attrs.Version = $attrs.Version -replace "\.\*$", ""
    }
    $attrs.Description = Get-AssemblyAttr "AssemblyDescription"
    $attrs.Company = Get-AssemblyAttr "AssemblyCompany"
    $attrs.Product = Get-AssemblyAttr "AssemblyProduct"
    $attrs.Authors = $attrs.Company
    if (-not $attrs.Authors) { $attrs.Authors = "Unknown" }
    $attrs.Copyright = Get-AssemblyAttr "AssemblyCopyright"
    return $attrs
}

function Get-AssemblyAttr($name) {
    $pattern = "\[assembly:\s*$name\(""([^""]*)""\)\]"
    $match = $assemblyInfo -match $pattern
    if ($match) {
        return ($assemblyInfo | Select-String -Pattern $pattern).Matches[0].Groups[1].Value
    }
    return ""
}
