$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$templatesPath = Join-Path $repoRoot 'Templates.html'
$scriptPath = Join-Path $repoRoot 'src\templates.js'

if (-not (Test-Path $templatesPath)) {
    Write-Host "[FAIL] Missing Templates.html at $templatesPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $scriptPath)) {
    Write-Host "[FAIL] Missing src/templates.js at $scriptPath" -ForegroundColor Red
    exit 1
}

$templates = Get-Content -Raw -Path $templatesPath
$script = Get-Content -Raw -Path $scriptPath

$checks = @(
    @{ Name = 'Single script source active'; Pass = ($templates -match '<script src="\./src/templates\.js"></script>') -and -not ($templates -match '(?s)<script>(?!\s*</script>)') },
    @{ Name = 'Injections container exists'; Pass = $templates -match 'id="injections-container"' },
    @{ Name = 'Discharge Plan container exists'; Pass = $templates -match 'id="discharge-plan-container"' },
    @{ Name = 'DTC container exists'; Pass = $templates -match 'id="drug-treatment-court-report-container"' },

    @{ Name = 'Injections branch exists'; Pass = $script -match "selectedNoteType === 'injections'" },
    @{ Name = 'Injections options handled'; Pass = ($script -match "case 'vivitrol'") -and ($script -match "case 'sublocade'") -and ($script -match "case 'brixadi'") },
    @{ Name = 'Injections listeners update on input+change'; Pass = ($script -match "injectionTypeSelect\.addEventListener\('change'") -and ($script -match "el\.addEventListener\('input', updateFinalNote\)") -and ($script -match "el\.addEventListener\('change', updateFinalNote\)") },

    @{ Name = 'Discharge Plan branch exists'; Pass = $script -match "selectedNoteType === 'discharge-plan'" },
    @{ Name = 'Discharge helper functions exist'; Pass = ($script -match 'function updateDischargeOtherNeedsSummary\(') -and ($script -match 'function initializeDischargeMedicationRows\(') },
    @{ Name = 'Discharge listeners wired'; Pass = ($script -match 'dischargeAddMedicationBtn') -and ($script -match 'dischargeSummaryCopyBtn\.addEventListener') },
    @{ Name = 'Copy area hides for Discharge Plan'; Pass = $script -match 'hideCopyAreaForDischargePlan' },

    @{ Name = 'DTC branch exists'; Pass = $script -match "selectedNoteType === 'drug-treatment-court-report'" },
    @{ Name = 'DTC dual-copy wiring exists'; Pass = ($script -match 'dtc-progress-note-copy') -and ($script -match 'dtc-court-note-copy') },
    @{ Name = 'DTC validation hook exists'; Pass = $script -match 'validateDtcRequiredFields' }
)

$failed = @()
foreach ($check in $checks) {
    if ($check.Pass) {
        Write-Host "[PASS] $($check.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $($check.Name)" -ForegroundColor Red
        $failed += $check
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`nSmoke check failed: $($failed.Count) check(s) failed." -ForegroundColor Red
    exit 1
}

Write-Host "`nSmoke check passed." -ForegroundColor Green
exit 0