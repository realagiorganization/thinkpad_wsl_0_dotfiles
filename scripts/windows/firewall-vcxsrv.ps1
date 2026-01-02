param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $env:USERPROFILE ("vcxsrv-firewall-diag-{0}.log" -f $timestamp)

Start-Transcript -Path $logPath | Out-Null

Write-Host "VcXsrv firewall reset starting at $timestamp"
Write-Host "Log: $logPath"

$rulePrefix = "VcXsrv X11"
$rulesToRemove = Get-NetFirewallRule -DisplayName "$rulePrefix*" -ErrorAction SilentlyContinue

if ($rulesToRemove) {
    Write-Host "Removing existing VcXsrv rules..."
    if ($WhatIf) {
        $rulesToRemove | Format-Table -Property DisplayName, Enabled, Direction, Action, Profile -AutoSize
    } else {
        $rulesToRemove | Remove-NetFirewallRule
    }
} else {
    Write-Host "No existing VcXsrv rules found."
}

$vcxsrvPath = "C:\Program Files\VcXsrv\vcxsrv.exe"
$rules = @(
    @{
        DisplayName = "VcXsrv X11 Inbound TCP 6000 (Any, Edge)"
        Params      = @{
            Direction          = "Inbound"
            Action             = "Allow"
            Protocol           = "TCP"
            LocalPort          = 6000
            Profile            = "Any"
            EdgeTraversalPolicy = "Allow"
        }
    },
    @{
        DisplayName = "VcXsrv X11 Inbound TCP 6000 (App)"
        Params      = @{
            Direction = "Inbound"
            Action    = "Allow"
            Protocol  = "TCP"
            LocalPort = 6000
            Profile   = "Any"
            Program   = $vcxsrvPath
        }
    },
    @{
        DisplayName = "VcXsrv X11 Inbound TCP 6000 (vEthernet WSL)"
        Params      = @{
            Direction      = "Inbound"
            Action         = "Allow"
            Protocol       = "TCP"
            LocalPort      = 6000
            Profile        = "Any"
            InterfaceAlias = "vEthernet (WSL)"
        }
    },
    @{
        DisplayName = "VcXsrv X11 Inbound TCP 6000 (WSL subnet)"
        Params      = @{
            Direction     = "Inbound"
            Action        = "Allow"
            Protocol      = "TCP"
            LocalPort     = 6000
            Profile       = "Any"
            RemoteAddress = "192.168.208.0/20"
        }
    }
)

Write-Host "Creating fresh VcXsrv rules..."
foreach ($rule in $rules) {
    if ($WhatIf) {
        Write-Host "Would create: $($rule.DisplayName)"
        $rule.Params | Format-Table -AutoSize
    } else {
        New-NetFirewallRule -DisplayName $rule.DisplayName @($rule.Params)
    }
}

Write-Host "Diagnostics:"
Get-NetConnectionProfile | Format-Table -AutoSize
Get-NetTCPConnection -LocalPort 6000 -State Listen -ErrorAction SilentlyContinue | Format-Table -AutoSize

Write-Host "Active VcXsrv rules:"
Get-NetFirewallRule -DisplayName "$rulePrefix*" |
    Select-Object DisplayName, Enabled, Direction, Action, Profile |
    Format-Table -AutoSize

Write-Host "Blocked inbound rules on port 6000:"
Get-NetFirewallRule -Action Block -Direction Inbound -ErrorAction SilentlyContinue |
    Get-NetFirewallPortFilter |
    Where-Object { $_.LocalPort -eq 6000 } |
    Format-Table -AutoSize

Write-Host "Firewall log (last 50 lines):"
Get-Content "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log" -ErrorAction SilentlyContinue |
    Select-Object -Last 50

Stop-Transcript | Out-Null
