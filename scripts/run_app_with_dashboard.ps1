param(
  [string]$Device = "",
  [int]$DashboardPort = 5764,
  [switch]$SkipBuild,
  [switch]$DashboardOnly,
  [switch]$OpenDashboard
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$serverOut = Join-Path $projectRoot ".admin_dashboard_server.out.log"
$serverErr = Join-Path $projectRoot ".admin_dashboard_server.err.log"
$dashboardUrl = "http://127.0.0.1:$DashboardPort/admin"

Set-Location $projectRoot

if (-not $SkipBuild -or -not (Test-Path (Join-Path $projectRoot "build\web\index.html"))) {
  flutter build web
}

$listener = Get-NetTCPConnection -LocalPort $DashboardPort -State Listen -ErrorAction SilentlyContinue
if (-not $listener) {
  Remove-Item -LiteralPath $serverOut, $serverErr -ErrorAction SilentlyContinue
  Start-Process `
    -FilePath "dart" `
    -ArgumentList @("run", "tool/serve_admin_dashboard.dart", "--port", "$DashboardPort") `
    -WorkingDirectory $projectRoot `
    -RedirectStandardOutput $serverOut `
    -RedirectStandardError $serverErr `
    -WindowStyle Hidden

  $deadline = (Get-Date).AddSeconds(20)
  do {
    Start-Sleep -Milliseconds 500
    $listener = Get-NetTCPConnection -LocalPort $DashboardPort -State Listen -ErrorAction SilentlyContinue
  } while (-not $listener -and (Get-Date) -lt $deadline)
}

if (-not $listener) {
  Write-Error "No se pudo levantar el dashboard en $dashboardUrl. Revisa $serverErr."
}

Write-Host "Dashboard admin: $dashboardUrl"

if ($OpenDashboard) {
  Start-Process $dashboardUrl
}

if ($DashboardOnly) {
  return
}

$flutterArgs = @("run")
if ($Device) {
  $flutterArgs += @("-d", $Device)
}

& flutter @flutterArgs
