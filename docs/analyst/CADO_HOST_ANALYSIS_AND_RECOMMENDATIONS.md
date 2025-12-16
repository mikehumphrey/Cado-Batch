# CADO Host Analysis & Collection Recommendations

**Analysis Date:** December 12, 2025  
**Reference Log:** cado-host.log (v3.9.0)  
**Purpose:** Evaluate data sources collected by Cado Host to determine suitability for Cado-Batch implementation

---

## Executive Summary

Cado Host is a comprehensive forensic collection tool that captures 1,387+ files across 15+ data source categories. This analysis identifies which data sources are most valuable for Cado-Batch integration and whether they align with the tool's forensic investigation goals.

**Key Findings:**
- ✅ **High-Value Sources:** 6 categories that should be prioritized
- ✅ **Medium-Value Sources:** 5 categories worth selective implementation
- ⚠️ **Lower Priority:** 6 categories better handled by specialized tools
- 🔴 **Not Applicable:** Some sources require special handling or configuration

---

## Data Sources Collected by Cado Host

### 1. **Event Logs** (Essential ⭐⭐⭐⭐⭐)

**Currently Collected:**
- 180+ `.evtx` files from `C:\Windows\System32\winevt\logs`
- Application, System, Security, Setup events
- PowerShell logs (Admin, Operational)
- Windows Defender, Firewall, RDP, Task Scheduler logs
- Kernel, Authentication (NTLM), Network events

**Forensic Value:** CRITICAL
- **Timeline reconstruction:** Exact timestamps of user actions
- **Authentication audit:** Logon events, credential use, privilege escalation
- **Malware detection:** Process execution, driver loading, suspicious activity
- **System changes:** Software installation, configuration changes
- **Network activity:** Remote access attempts, data exfiltration indicators

**Recommendation for Cado-Batch:**
✅ **YES - High Priority (Phase 1)**
- Use existing collect.ps1 to gather `.evtx` files
- Store in `collected_files\EventLogs\` directory
- Include SHA256 hashing (already in Phase 1)
- Extract to human-readable format for analysis

**Implementation:**
```powershell
# Already collects in current script
robocopy "C:\Windows\System32\winevt\logs" "$outputDir\EventLogs" *.evtx /R:1 /W:1
```

---

### 2. **Registry Hives** (Essential ⭐⭐⭐⭐⭐)

**Currently Collected:**
- SYSTEM hive + transaction logs (LOG1, LOG2)
- SOFTWARE hive + transaction logs
- SAM hive + transaction logs (user credentials)
- SECURITY hive + transaction logs
- NTUSER.DAT per user + transaction logs
- UsrClass.dat per user + transaction logs

**Forensic Value:** CRITICAL
- **Last logon times:** User activity tracking
- **USB device history:** Removable media connections
- **Network shares:** Accessed file shares
- **Installed software:** Programs and versions
- **Windows updates:** Patch history and gaps
- **User preferences:** Desktop configuration, settings
- **Recently used files:** User activity indicators
- **Windows activation:** Licensing and device identity

**Recommendation for Cado-Batch:**
✅ **YES - High Priority (Phase 1)**
- Use RawCopy.exe to extract locked registry hives
- Store with folder structure preserved
- Include with SHA256 manifest

**Implementation:**
```powershell
# Registry hive collection (Phase 1 enhancement)
$registryHives = @(
    "C:\Windows\System32\config\SYSTEM",
    "C:\Windows\System32\config\SOFTWARE",
    "C:\Windows\System32\config\SAM",
    "C:\Windows\System32\config\SECURITY"
)
foreach ($hive in $registryHives) {
    & $rawCopyPath /FileNamePath:$hive /OutputPath:$outputDir\Registry\
}
```

---

### 3. **Prefetch Files** (Important ⭐⭐⭐⭐)

**Currently Collected:**
- 500+ `.pf` files from `C:\Windows\Prefetch`
- Each file contains last 8 execution times
- DLL and registry access patterns

**Forensic Value:** HIGH
- **Program execution history:** Which programs ran and when
- **Persistence mechanisms:** Auto-start programs
- **Malware indicators:** Unusual system utility execution
- **Timeline data:** Execution timestamps for correlation
- **System reconnaissance:** What tools attacker used

**Recommendation for Cado-Batch:**
✅ **YES - Phase 2** (parse .pf files)
- Collect raw `.pf` files (already done)
- Parse with dedicated tool for readable output
- Extract execution times and PE names

**Tools for Parsing:**
- **WinPrefetchView** (free, lightweight)
- **PECmd** (SANS Investigative Forensics Toolkit)
- **Analysis plugin-based approach**

---

### 4. **Scheduled Tasks** (Important ⭐⭐⭐⭐)

**Currently Collected:**
- 200+ scheduled task XML files from `C:\Windows\System32\Tasks\`
- Subdirectories for Microsoft, Office, VMware, custom tasks
- `.job` files from `C:\Windows\Tasks\`

**Forensic Value:** HIGH
- **Persistence indicators:** Scheduled task-based malware
- **Maintenance tasks:** System background operations
- **User-created tasks:** Non-standard automation
- **Execution timing:** When tasks are scheduled to run
- **Credential context:** User accounts running tasks

**Recommendation for Cado-Batch:**
✅ **YES - Phase 1**
- Collect task XML files
- Parse for non-standard scheduled tasks
- Focus on tasks in `C:\Windows\System32\Tasks\` (non-Microsoft)

**New Data for Collection:**
```powershell
# Identify suspicious scheduled tasks
$systemTasks = Get-ChildItem "C:\Windows\System32\Tasks" -Recurse -Filter "*.xml"
foreach ($task in $systemTasks) {
    [xml]$taskXml = Get-Content $task.FullName
    # Parse for suspicious content
    if ($taskXml.Task.Actions.Exec.Command -match "powershell|cmd|certutil|mshta") {
        "SUSPICIOUS_TASK: $($task.Name)" | Add-Content "$outputDir\SuspiciousTasks.txt"
    }
}
```

---

### 5. **LNK/Shortcut Files** (Important ⭐⭐⭐⭐)

**Currently Collected:**
- 400+ `.lnk` files from user profiles
- Recent files shortcuts
- Start menu shortcuts
- AutomaticDestinations jump lists
- CustomDestinations jump lists

**Forensic Value:** HIGH
- **User activity:** What applications user accessed
- **Recent file access:** Files user opened recently
- **USB history:** Shortcuts to external drives
- **Cloud storage:** OneDrive, SharePoint access
- **Timeline indicators:** When shortcuts were created/modified

**Recommendation for Cado-Batch:**
✅ **YES - Phase 1**
- Collect all `.lnk` and `.automaticDestinations-ms` files
- Parse jump lists for recent items
- Extract target paths and dates

**New Data for Collection:**
```powershell
# Parse jump lists for recent activity
$recent = Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent" -Recurse -Filter "*.lnk"
foreach ($link in $recent) {
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($link.FullName)
    "$($link.Name) -> $($lnk.TargetPath)" | Add-Content "$outputDir\RecentActivity.txt"
}
```

---

### 6. **Windows Search Index** (Important ⭐⭐⭐)

**Currently Collected:**
- Windows Search database files
  - `Windows-gather.db` (600+ MB)
  - `Windows-usn.db` 
  - `Windows.db` (current search index)

**Forensic Value:** HIGH
- **File enumeration:** Complete file list with timestamps
- **Deleted files:** Often indexed before deletion
- **File content snippets:** Indexed content preview
- **Metadata:** File sizes, dates, locations
- **User search history:** What user searched for

**Recommendation for Cado-Batch:**
✅ **YES - Phase 2** (requires specialized parsing)
- Collect Windows Search database files
- Parse with ESEDatabaseView or similar
- Extract file listings and metadata
- Identify recently deleted files

**Tools Needed:**
- **ESEDatabaseView** - browse ESE database
- **INDXParse** - parse NTFS INDEX records
- **Python-ese** - programmatic access

---

### 7. **Browser Data** (Important ⭐⭐⭐⭐)

**Currently Collected:**

**Microsoft Edge:**
- Bookmarks
- Browsing history (implicit via parent folders)
- Favicons
- Collections (reading lists)

**Internet Explorer Cache:**
- WebCache database files
- Cookie ESE database
- History container files

**Forensic Value:** VERY HIGH
- **Web activity:** Websites visited
- **Bookmarks:** User interests and saved resources
- **Cookies:** Session tracking and authentication
- **Downloaded files:** File download history
- **Form data:** Sensitive information submission

**Gaps in Current Collection:**
- ❌ Chrome history (not collected - popular browser)
- ❌ Firefox history (not collected)
- ❌ Cookie files (partially collected)
- ❌ Download history (not explicitly collected)

**Recommendation for Cado-Batch:**
✅ **YES - Phase 1 (Enhanced)**
- Add Chrome history, bookmarks, downloads
- Add Firefox history and bookmarks
- Collect browser cache for artifact recovery
- Parse for timeline indicators

**New Data for Collection:**
```powershell
# Enhanced browser data collection
$browsers = @{
    "Chrome" = "$env:LOCALAPPDATA\Google\Chrome\User Data"
    "Firefox" = "$env:APPDATA\Mozilla\Firefox\Profiles"
    "Edge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
}

foreach ($browser in $browsers.GetEnumerator()) {
    if (Test-Path $browser.Value) {
        robocopy $browser.Value "$outputDir\Browsers\$($browser.Key)" /S /R:1 /W:1
    }
}
```

---

### 8. **Prefetch/Executive History** (Important ⭐⭐⭐⭐)

**Currently Collected:**
- Amcache.hve
- Recent File Cache (.bcf)

**Forensic Value:** HIGH
- **Long-term execution history:** Days/weeks of program execution
- **File associations:** What programs opened what files
- **Device and file interaction:** USB and removable media
- **Session history:** When Windows sessions began/ended

**Recommendation for Cado-Batch:**
✅ **YES - Phase 2**
- Parse Amcache for program execution history
- Extract timestamps and file paths
- Correlate with prefetch data for full timeline

---

### 9. **User Activity Data**

**Currently Collected:**
- Thumb cache (thumbnail database)
- Shell icons and start menu
- Quick links
- Desktop shortcuts

**Currently MISSING:**
- ❌ SRUM (System Resource Usage Monitor) detailed parsing
- ⚠️ User activity timeline database
- ⚠️ Windows 10 Timeline activity history

**Forensic Value:** MEDIUM-HIGH
- **Application usage:** Which programs used most
- **Timeline:** Approximate activity windows
- **Resource consumption:** High CPU/memory events

**Recommendation:**
✅ **YES - Phase 2**
- Parse SRUM database for resource timeline
- Extract network activity indicators
- Correlate with process execution

---

### 10. **Memory and Volatile Data**

**Currently NOT Collected:**
- ❌ RAM dump
- ❌ Pagefile
- ❌ Hibernation file
- ❌ Network connections (live netstat)
- ❌ Open files (live lsof equivalent)

**Forensic Value:** CRITICAL (for malware investigation)

**Recommendation:**
✅ **YES - Phase 3 (Optional)**
- Add live network connection capture
- Capture open file handles
- Extract process memory if needed
- Document network listening ports

**Implementation (Phase 3):**
```powershell
# Volatile data collection
$netstat = Get-NetTCPConnection -State Established | Export-Csv "$outputDir\NetworkConnections.csv"
$handles = Get-Process | ForEach-Object { Handle -p $_.Id } | Out-File "$outputDir\OpenHandles.txt"
```

---

### 11. **Application-Specific Artifacts** (Lower Priority)

**Email Applications:**
- ⚠️ Outlook cache (PST files if present)
- ✅ Thunderbird profile (if configured)

**Document Storage:**
- ✅ OneDrive cache
- ✅ Office recent files
- ✅ PDF viewer history (if Adobe Reader)

**Forensic Value:** MEDIUM
- Email content (if PST accessible)
- Recently edited documents
- Cloud storage activity

**Recommendation:**
⚠️ **PARTIAL - Phase 2**
- Focus on recent files and cache
- Skip full PST extraction (privacy concerns)
- Target cloud storage sync folders

---

### 12. **Not Applicable to Cado-Batch**

**Why These Are Skipped:**

1. **Cloud Metadata Collection** (AWS metadata fetch)
   - ✅ Correct: Cado Host checks for AWS environment
   - ⚠️ Not needed for on-premises servers

2. **Screenshot Plugin**
   - ✅ Correct: Captures desktop state
   - ⚠️ Privacy and GUI concerns on server
   - 🔴 Not suitable for headless collection

3. **Memory Collection**
   - ✅ Correct: Captures volatile malware
   - ⚠️ Requires WinPMEM or similar
   - 🔴 Large file size (RAM amount)

4. **Network Packet Capture**
   - ✅ Correct: Captures network behavior
   - ⚠️ Requires packet driver
   - 🔴 Not included in Cado Host by default

---

## Summary: What to Collect for Cado-Batch

### ✅ **Phase 1 (Already Implemented)**
Current: Event logs, Registry hives, LNK files, Prefetch, Scheduled tasks
- [x] Event logs (1,387 files)
- [x] Registry hives
- [x] LNK/jump lists
- [x] Prefetch files
- [x] Scheduled tasks
- [x] Signature verification (sigcheck.exe)
- [x] Hash verification (hashdeep.exe)
- [x] String extraction (strings.exe)

### 🔵 **Phase 2 (Recommended Next)**
High-value targets from Cado Host analysis:
1. **Browser history parsing**
   - Chrome bookmarks and history
   - Firefox bookmarks and history
   - Browser download history
2. **Advanced artifact parsing**
   - Prefetch file parsing (human-readable timeline)
   - Jump list database extraction
   - Windows Search index parsing
   - Amcache program execution timeline
3. **Additional data sources**
   - SRUM database (resource usage timeline)
   - Office recent documents
   - Windows 10 Timeline activity

### 🟡 **Phase 3 (Future Consideration)**
1. **Volatile data capture**
   - Live network connections
   - Open file handles
   - Running processes with full command-line
   - Loaded DLLs per process
2. **Advanced malware indicators**
   - Process injection detection
   - Unsigned driver loading
   - Network anomalies

---

## Data Size Recommendations

**Expected Collection Sizes (per server):**

| Category | Files | Size | Priority |
|----------|-------|------|----------|
| Event Logs | 180 | 500 MB - 2 GB | ⭐⭐⭐⭐⭐ |
| Registry | 15 | 100 - 500 MB | ⭐⭐⭐⭐⭐ |
| Prefetch | 500 | 5 - 20 MB | ⭐⭐⭐⭐ |
| LNK/Jump Lists | 400 | 2 - 10 MB | ⭐⭐⭐⭐ |
| Windows Search | 3 | 500 MB - 2 GB | ⭐⭐⭐ |
| Browser Data | 50+ | 10 - 50 MB | ⭐⭐⭐⭐ |
| Scheduled Tasks | 200 | 1 - 5 MB | ⭐⭐⭐⭐ |
| **TOTAL** | **~1,400** | **~1.2 - 4 GB** | - |

**Cado Host Actual:** 1,387 files in compressed tar.lz4 format (compression ratio ~50-70%)

---

## Key Insights for Cado-Batch Design

### 1. **Event Logs are Essential**
- Enables timeline reconstruction
- Shows authentication and network activity
- Identifies persistence mechanisms
- Already being collected ✅

### 2. **Registry Analysis is Critical**
- Complete system and user configuration
- Last logon times and connected networks
- Installed software with versions
- Already being collected ✅

### 3. **Browser History Often Overlooked**
- Shows user objectives and targets
- Reveals social engineering attacks
- Indicates data exfiltration
- Partially collected (Edge only)
- **RECOMMENDATION:** Expand to Chrome/Firefox

### 4. **Prefetch Provides Timeline**
- 8 execution timestamps per program
- Shows which tools attacker used
- Covers weeks of system activity
- Already collected but not parsed
- **RECOMMENDATION:** Add parsing tool

### 5. **Multiple Data Sources Needed for Solid Timeline**
- Event logs: system events
- Prefetch: program execution
- LNK files: user activity
- Browser history: web activity
- SRUM: resource usage timeline
- All provide different perspectives

---

## Recommended Additions to Cado-Batch

### 1. **Expand Browser Collection**
Add Chrome and Firefox data extraction to Phase 1 or 2

### 2. **Add Prefetch Parser**
Implement human-readable extraction of .pf files

### 3. **Add Browser History Parser**
Extract and normalize Chrome/Firefox/Edge history

### 4. **Add SRUM Parser**
Extract system resource usage for timeline

### 5. **Add Amcache Parser**
Extract program execution history

### 6. **Add Suspicious Task Detection**
Flag scheduled tasks with suspicious commands (powershell, cmd, certutil)

---

## Conclusion

Cado Host collects a comprehensive set of forensic artifacts that align well with Cado-Batch's goals. The current Phase 1 implementation covers the highest-value data sources (event logs, registry, executables). Recommended Phase 2 additions would focus on:

1. **Parser tools** for existing data (Prefetch, Jump Lists, Registry)
2. **Browser history** extraction (Chrome/Firefox)
3. **Advanced timeline** generation (SRUM, Amcache)
4. **Threat detection** (suspicious tasks, indicators of compromise)

These additions would transform Cado-Batch from a raw data collector into an **analytical platform** that can help analysts quickly identify compromises and construct timelines.

---

**Document Version:** 1.0  
**Last Updated:** December 12, 2025  
**Prepared For:** Cado-Batch Phase 2 Planning

