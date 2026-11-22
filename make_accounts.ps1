$FileName = "accounts.json"

function Get-OfflineUuid($Name) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $b = $md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("OfflinePlayer:" + $Name))
    $b[6] = ($b[6] -band 0x0F) -bor 0x30
    $b[8] = ($b[8] -band 0x3F) -bor 0x80
    $h = ($b | ForEach-Object { $_.ToString("x2") }) -join ""
    return "{0}-{1}-{2}-{3}-{4}" -f $h.Substring(0,8), $h.Substring(8,4), $h.Substring(12,4), $h.Substring(16,4), $h.Substring(20)
}

function Ask-YesNo($Prompt) {
    while ($true) {
        $a = (Read-Host "$Prompt [y/n]").Trim().ToLower()
        if ($a -eq "y" -or $a -eq "yes") { return $true }
        if ($a -eq "n" -or $a -eq "no") { return $false }
        Write-Host "Please answer y or n."
    }
}

function Ask-Text($Prompt) {
    while ($true) {
        $a = (Read-Host $Prompt).Trim()
        if ($a -ne "") { return $a }
        Write-Host "This can't be empty."
    }
}

function Ask-Int($Prompt, $Min = 1, $Max = 100, $Default = $null) {
    while ($true) {
        $a = (Read-Host $Prompt).Trim()
        if ($a -eq "" -and $null -ne $Default) { return $Default }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and $n -ge $Min -and $n -le $Max) { return $n }
        Write-Host "Please enter a whole number from $Min to $Max."
    }
}

function Get-Directory {
    while ($true) {
        $raw = (Read-Host "Sklauncher Folder (press Enter for the current folder)").Trim().Trim('"').Trim("'")
        if ($raw -eq "") { $raw = (Get-Location).Path }
        if ($raw -eq "~" -or $raw.StartsWith("~\") -or $raw.StartsWith("~/")) {
            $raw = $HOME + $raw.Substring(1)
        }
        $raw = [Environment]::ExpandEnvironmentVariables($raw)
        if (-not [System.IO.Path]::IsPathRooted($raw)) {
            $raw = Join-Path (Get-Location).Path $raw
        }
        if (Test-Path -LiteralPath $raw -PathType Container) { return $raw }
        if (Ask-YesNo "'$raw' doesn't exist. Create it?") {
            try {
                New-Item -ItemType Directory -Path $raw -Force -ErrorAction Stop | Out-Null
                return $raw
            } catch {
                Write-Host "Couldn't create it: $($_.Exception.Message)"
            }
        }
    }
}

# ---------------------------------------------------------------------------

$directory = Get-Directory
$path = Join-Path $directory $FileName

if (Test-Path -LiteralPath $path) {
    Write-Host ""
    Write-Host "Warning: $path already exists." -ForegroundColor Yellow
    Write-Host "Continuing will replace it with a new file."
    if (-not (Ask-YesNo "Do you want to override it?")) {
        Write-Host "Cancelled. Nothing was changed."
        return
    }
}

Write-Host ""
$count = Ask-Int "How many accounts do you want to add" 1 50 1

$accounts = New-Object System.Collections.ArrayList
$ids = New-Object System.Collections.ArrayList
$usernames = New-Object System.Collections.ArrayList

for ($i = 1; $i -le $count; $i++) {
    Write-Host ""
    Write-Host "Account $i of $count" -ForegroundColor Cyan

    # IDs are automatic: Account 1, Account 2, ...
    $id = "Account $i"

    Write-Host "Make sure to type your actual username."
    $username = Ask-Text "Username"

    $uuid = Get-OfflineUuid $username

    [void]$ids.Add($id)
    [void]$usernames.Add($username)
    [void]$accounts.Add([ordered]@{
        id       = $id
        type     = "offline"
        username = $username
        uuid     = $uuid
    })
}

if ($count -eq 1) {
    $active = $ids[0]
} else {
    Write-Host ""
    Write-Host "Which account should be active (selected)?" -ForegroundColor Cyan
    for ($i = 0; $i -lt $count; $i++) {
        Write-Host ("  {0}) {1} ({2})" -f ($i + 1), $ids[$i], $usernames[$i])
    }
    $pick = Ask-Int "Pick a number" 1 $count
    $active = $ids[$pick - 1]
}

$result = [ordered]@{
    accounts        = $accounts
    activeAccountId = $active
}

try {
    $json = $result | ConvertTo-Json -Depth 10
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $json, $utf8NoBom)
    Write-Host ""
    Write-Host "Done! Saved $count account(s) to:" -ForegroundColor Green
    Write-Host "  $path"
    Write-Host "Active account: $active"
} catch {
    Write-Host "Couldn't write the file: $($_.Exception.Message)" -ForegroundColor Red
}
