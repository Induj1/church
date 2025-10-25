<#
Run this script to apply SQL migrations to your Postgres database.

Usage (PowerShell):
  # Set the Postgres connection string in the environment (recommended):
  $env:PG_CONN_STRING = 'postgresql://<user>:<password>@<host>:<port>/<database>'
  .\run_migration.ps1

Notes:
- Requires `psql` (Postgres CLI) available in PATH.
- Alternatively paste the SQL in `admin_server/migrations/001_add_content_type_thumbnail.sql` into the Supabase SQL editor and run.
#>

param(
  [string]$MigrationFile = "migrations/001_add_content_type_thumbnail.sql"
)

if (-not $env:PG_CONN_STRING) {
  Write-Error "Environment variable PG_CONN_STRING is not set. Set it to your Postgres connection string and re-run."
  exit 2
}

$psql = "psql"
if (-not (Get-Command $psql -ErrorAction SilentlyContinue)) {
  Write-Error "psql not found in PATH. Install PostgreSQL client tools or use the Supabase SQL editor instead."
  exit 3
}

$fullPath = Join-Path $PSScriptRoot $MigrationFile
if (-not (Test-Path $fullPath)) {
  Write-Error "Migration file not found: $fullPath"
  exit 4
}

Write-Output "Applying migration: $fullPath"
& $psql $env:PG_CONN_STRING -f $fullPath
$rc = $LASTEXITCODE
if ($rc -ne 0) {
  Write-Error "psql exited with code $rc"
  exit $rc
}

Write-Output "Migration applied successfully."
