<#
.SYNOPSIS
    Validates that the Cado-Batch project structure is properly organized.
    
.DESCRIPTION
    Checks that all required folders, scripts, and tools are in the correct
    locations per PROJECT_STRUCTURE.md. Output is saved to VALIDATE_PROJECT_STRUCTURE.log
    
.EXAMPLE
    .\VALIDATE_PROJECT_STRUCTURE.ps1
    
.NOTES
    Saves output to VALIDATE_PROJECT_STRUCTURE.log in the project root
#>

$ErrorActionPreference = 'Continue'
$scriptPath = $PSScriptRoot
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = Join-Path $scriptPath "VALIDATE_PROJECT_STRUCTURE.log"

# Start fresh log
"═══════════════════════════════════════════════════════════════" | Set-Content $logFile
"Cado-Batch Project Structure Validation Log" | Add-Content $logFile
"═══════════════════════════════════════════════════════════════" | Add-Content $logFile
"Validation Started: $timestamp" | Add-Content $logFile
"Project Root: $scriptPath" | Add-Content $logFile
"" | Add-Content $logFile

# Track results
$passed = 0
$failed = 0
$warnings = 0

# Logging function - writes to both console and log file
function Write-LogEntry {
    param(
        [string]$Message
    )
    # Write to log file
    Add-Content -Path $logFile -Value $Message
    # Also write to console
    Write-Host $Message
}

# ============================================================================
# HEADER
# ============================================================================

Write-LogEntry "-------------------------------------------------------------"
Write-LogEntry "Cado-Batch Project Structure Validation"
Write-LogEntry "Checking organization per PROJECT_STRUCTURE.md"
Write-LogEntry "-------------------------------------------------------------"
Write-LogEntry ""

# ============================================================================
# 1. FOLDER STRUCTURE
# ============================================================================

Write-LogEntry "1. FOLDER STRUCTURE"
Write-LogEntry "-------------------------------------------------------------"

$folders = @(
    @{name="source"; desc="Collection scripts"},
    @{name="tools"; desc="Executables and utilities"},
    @{name="investigations"; desc="Investigation results"},
    @{name="templates"; desc="Output templates"},
    @{name="documentation"; desc="Guides and references"},
    @{name="logs"; desc="Collection logs (created at runtime)"}
)

foreach ($folder in $folders) {
    $folderPath = Join-Path $scriptPath $folder.name
    if (Test-Path $folderPath -PathType Container) {
        Write-LogEntry ("  [PASS] " + $folder.name + "/ - " + $folder.desc)
        $passed++
    } else {
        Write-LogEntry ("  [FAIL] " + $folder.name + "/ - " + $folder.desc + " [NOT FOUND]")
        $failed++
    }
}

# ============================================================================
# 2. SCRIPTS IN source/
# ============================================================================

Write-LogEntry ""
Write-LogEntry "2. COLLECTION SCRIPTS (source/)"
Write-LogEntry "-------------------------------------------------------------"

$scripts = @("collect.ps1", "RUN_ME.bat", "collect.bat", "deploy_multi_server.ps1")

foreach ($script in $scripts) {
    $scriptFile = Join-Path $scriptPath "source\$script"
    if (Test-Path $scriptFile -PathType Leaf) {
        $size = (Get-Item $scriptFile).Length / 1KB
        $sizeRounded = [math]::Round($size, 0)
        Write-LogEntry ("  [PASS] " + $script + " (" + $sizeRounded + " KB)")
        $passed++
    } else {
        Write-LogEntry ("  [FAIL] " + $script + " [NOT FOUND]")
        $failed++
    }
}

# ============================================================================
# 3. PHASE 1 TOOLS IN tools/bins/
# ============================================================================

Write-LogEntry ""
Write-LogEntry "3. PHASE 1 TOOLS (tools/bins/)"
Write-LogEntry "-------------------------------------------------------------"

$tools = @(
    "hashdeep.exe",
    "hashdeep64.exe",
    "strings.exe",
    "strings64.exe",
    "sigcheck.exe",
    "sigcheck64.exe",
    "RawCopy.exe",
    "zip.exe"
)

$toolsPath = Join-Path $scriptPath "tools\bins"

foreach ($tool in $tools) {
    $toolFile = Join-Path $toolsPath $tool
    if (Test-Path $toolFile -PathType Leaf) {
        $actualSize = (Get-Item $toolFile).Length / 1KB
        $actualSizeRounded = [math]::Round($actualSize)
        Write-LogEntry ("  [PASS] " + $tool + " (" + $actualSizeRounded + " KB)")
        $passed++
    } else {
        Write-LogEntry ("  [FAIL] " + $tool + " [NOT FOUND]")
        $failed++
    }
}

# ============================================================================
# 4. TEMPLATES
# ============================================================================

Write-LogEntry ""
Write-LogEntry "4. TEMPLATES"
Write-LogEntry "-------------------------------------------------------------"

$templates = @(
    "investigation_metadata_template.txt",
    "incident_log_template.txt"
)

$templatesPath = Join-Path $scriptPath "templates"

foreach ($template in $templates) {
    $templateFile = Join-Path $templatesPath $template
    if (Test-Path $templateFile -PathType Leaf) {
        $size = (Get-Item $templateFile).Length / 1KB
        $sizeRounded = [math]::Round($size, 1)
        Write-LogEntry ("  [PASS] " + $template + " (" + $sizeRounded + " KB)")
        $passed++
    } else {
        Write-LogEntry ("  [FAIL] " + $template + " [NOT FOUND]")
        $failed++
    }
}

# ============================================================================
# 5. KEY DOCUMENTATION
# ============================================================================

Write-LogEntry ""
Write-LogEntry "5. KEY DOCUMENTATION FILES"
Write-LogEntry "-------------------------------------------------------------"

$docs = @(
    "PROJECT_STRUCTURE.md",
    "QUICK_START.md",
    "PHASE_2_IMPLEMENTATION_COMPLETE.md",
    "README.md"
)

foreach ($doc in $docs) {
    $docFile = Join-Path $scriptPath $doc
    if (Test-Path $docFile -PathType Leaf) {
        Write-LogEntry ("  [PASS] " + $doc)
        $passed++
    } else {
        Write-LogEntry ("  [WARN] " + $doc + " [NOT FOUND]")
        $warnings++
    }
}

# ============================================================================
# 6. OPTIONAL TOOLS
# ============================================================================

Write-LogEntry ""
Write-LogEntry "6. PHASE 2+ OPTIONAL TOOLS (Placeholders)"
Write-LogEntry "-------------------------------------------------------------"

$optionalTools = @("WinPrefetchView", "PECmd", "AmcacheParser")
$optionalPath = Join-Path $scriptPath "tools\optional"

foreach ($optTool in $optionalTools) {
    $optToolPath = Join-Path $optionalPath $optTool
    if (Test-Path $optToolPath -PathType Container) {
        Write-LogEntry ("  [PASS] " + $optTool + " - Directory ready for tool installation")
        $passed++
    } else {
        Write-LogEntry ("  [WARN] " + $optTool + " - Directory not found")
        $warnings++
    }
}

# ============================================================================
# 7. SUMMARY
# ============================================================================

Write-LogEntry ""
Write-LogEntry "VALIDATION SUMMARY"
Write-LogEntry "-------------------------------------------------------------"

$total = $passed + $failed + $warnings

Write-LogEntry ("  Passed:   " + $passed + " checks")
Write-LogEntry ("  Failed:   " + $failed + " checks")
Write-LogEntry ("  Warnings: " + $warnings + " checks")
Write-LogEntry "  ---------------------------------"
Write-LogEntry ("  Total:    " + $total + " checks")
Write-LogEntry ""

# ============================================================================
# DEPLOYMENT READINESS
# ============================================================================

if ($failed -eq 0) {
    Write-LogEntry "[PASS] PROJECT STRUCTURE IS READY FOR DEPLOYMENT"
    Write-LogEntry ""
    Write-LogEntry "  Next Steps:"
    Write-LogEntry "  -----------------------------------------------------------"
    Write-LogEntry "  1. Test single-server collection: .\source\RUN_ME.bat"
    Write-LogEntry "  2. Test multi-server deployment: .\source\deploy_multi_server.ps1 -Targets 'SERVER01','SERVER02'"
    Write-LogEntry "  3. Download optional tools when ready (Phase 2+ analysis):"
    Write-LogEntry "     - WinPrefetchView: https://www.nirsoft.net/utils/win_prefetch_view.html"
    Write-LogEntry "     - PECmd: https://github.com/EricZimmerman/PECmd/releases"
    Write-LogEntry "     - AmcacheParser: https://github.com/EricZimmerman/AmcacheParser/releases"
    Write-LogEntry ""
    Write-LogEntry "  Documentation:"
    Write-LogEntry "     -> PROJECT_STRUCTURE.md (full organization details)"
    Write-LogEntry "     -> QUICK_START.md (5-minute quick start)"
    Write-LogEntry "     -> documentation/PHASE_2_TESTING_GUIDE.md (validation tests)"
    Write-LogEntry ""
} else {
    Write-LogEntry "[FAIL] PROJECT STRUCTURE NEEDS ATTENTION"
    Write-LogEntry ("  " + $failed + " critical issue(s) found - review failures above")
    Write-LogEntry ""
}

Write-LogEntry "Validation Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-LogEntry "Log file location: $logFile"

Write-Host ""
Write-Host "[PASS] Validation complete! Log saved to: VALIDATE_PROJECT_STRUCTURE.log"
Write-Host ""
