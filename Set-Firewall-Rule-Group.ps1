# Set the group of a firewall rule

Param (
  [Parameter(Mandatory=$true)]
  [string] $Name,
  [Parameter(Mandatory=$true)]
  [string] $Group
)

$rule = Get-NetFirewallRule -DisplayName $Name
$rule.Group = $Group
$rule | Set-NetFirewallRule