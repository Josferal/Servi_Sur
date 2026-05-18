param(
  [int]$DashboardPort = 5764,
  [switch]$SkipBuild,
  [switch]$OpenDashboard
)

$runner = Join-Path $PSScriptRoot "run_app_with_dashboard.ps1"
& $runner `
  -DashboardPort $DashboardPort `
  -SkipBuild:$SkipBuild `
  -DashboardOnly `
  -OpenDashboard:$OpenDashboard
