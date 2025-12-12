#Requires -Version 5.1
<#
.SYNOPSIS
    This module contains functions for post-collection analysis of forensic data
    collected by the Cado-Batch toolset.
#>

function New-YaraRuleFromInput {
<#
.SYNOPSIS
    Dynamically generates a Yara rule from a given CSV input file.
.DESCRIPTION
    Reads a CSV file containing Filename and SHA256Hash columns and creates a 
    temporary Yara rule file (.yar) that can be used to scan for either attribute.
.PARAMETER InputFile
    The path to the CSV file containing the sensitive file information.
.PARAMETER TempRulePath
    The path where the temporary Yara rule will be saved.
#>
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile,
        [Parameter(Mandatory=$true)]
        [string]$TempRulePath
    )

    try {
        $sensitiveFiles = Import-Csv -Path $InputFile
    }
    catch {
        Write-Error "Failed to read or parse the CSV file at '$InputFile'. Please ensure it is a valid CSV with 'FileName' and 'SHA256Hash' headers."
        throw
    }

    $ruleHeader = @"
rule Sensitive_File_Detection
{
    strings:
"@
    $ruleFooter = @"
    condition:
        any of them
}
"@

    $stringConditions = @()
    foreach ($file in $sensitiveFiles) {
        $stringConditions += "`t`t`$fname_{0} = `"{1}`" nocase" -f ($stringConditions.Count + 1), $file.FileName
    }

    # Combine the parts into a final rule
    $finalRule = $ruleHeader + "`n" + ($stringConditions -join "`n") + "`n" + $ruleFooter
    
    Set-Content -Path $TempRulePath -Value $finalRule
    Write-Verbose "Successfully generated temporary Yara rule at $TempRulePath"
}

function Invoke-YaraScan {
<#
.SYNOPSIS
    Performs a post-collection Yara scan on collected forensic artifacts.
.DESCRIPTION
    This function scans previously collected artifacts from a Cado-Batch investigation.
    It dynamically generates a Yara rule based on a user-provided list of sensitive
    files (filenames and hashes) and scans the collected data for any traces of them.
.PARAMETER InvestigationPath
    The full path to a specific investigation timestamp folder 
    (e.g., .\investigations\Case_123\SERVER01\20251212_143022).
.PARAMETER YaraInputFile
    The path to the CSV file containing the sensitive file information.
    Must have 'FileName' and 'SHA256Hash' columns.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InvestigationPath,
        [Parameter(Mandatory=$true)]
        [string]$YaraInputFile
    )
    
    $yaraExecutable = ".\tools\yara\yara64.exe"
    if (-not (Test-Path $yaraExecutable)) {
        Write-Error "Yara executable not found at '$yaraExecutable'. Please download it from https://github.com/VirusTotal/yara/releases and place it in the tools\yara folder."
        return
    }

    $collectedFilesPath = Join-Path $InvestigationPath "collected_files"
    if (-not (Test-Path $collectedFilesPath)) {
        Write-Error "The specified investigation path does not contain a 'collected_files' directory. Please provide a valid path to a timestamped collection folder."
        return
    }

    $tempRuleFile = Join-Path $env:TEMP "cado_temp_rule.yar"
    $scanOutputFile = Join-Path $InvestigationPath "Phase3_Yara_Scan_Results.txt"

    try {
        Write-Host "1. Generating dynamic Yara rule from input file..." -ForegroundColor Cyan
        New-YaraRuleFromInput -InputFile $YaraInputFile -TempRulePath $tempRuleFile

        Write-Host "2. Starting Yara scan on collected artifacts at '$collectedFilesPath'..." -ForegroundColor Cyan
        
        $arguments = @(
            "-r", # Recursive scan
            $tempRuleFile,
            $collectedFilesPath
        )
        
        # Execute Yara and capture output
        $process = Start-Process -FilePath $yaraExecutable -ArgumentList $arguments -Wait -NoNewWindow -PassThru -RedirectStandardOutput $scanOutputFile
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ Scan complete. Results saved to '$scanOutputFile'." -ForegroundColor Green
        } else {
            Write-Warning "Yara scan completed with exit code $($process.ExitCode). Review the output file for details."
        }

    }
    finally {
        Write-Host "3. Cleaning up temporary files..." -ForegroundColor Cyan
        if (Test-Path $tempRuleFile) {
            Remove-Item $tempRuleFile -Force
        }
    }
}

Export-ModuleMember -Function Invoke-YaraScan
