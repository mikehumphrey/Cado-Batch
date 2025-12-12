# Cado Evidence Collector

A PowerShell script to collect forensic evidence from modern Windows systems (Windows 10, Windows 11, Server 2016+). This script modernizes the functionality of the original `collect.bat`.

## Data Collected

The script collects the following forensic artifacts:

-   **NTFS Metadata**:
    -   `$MFT` (Master File Table) from the system drive.
    -   `$LogFile` (NTFS Log File) from the system drive.
-   **Windows Event Logs**:
    -   All `.evtx` files from `%SystemRoot%\System32\winevt\logs\`.
-   **Registry Hives**:
    -   System hives: `SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, `DEFAULT` from `%SystemRoot%\System32\Config`.
    -   Administrator's user hive: `NTUSER.DAT` from the default administrator profile.
-   **System Information**:
    -   A recursive directory listing of the root of the system drive (`C:\`).

All collected data is placed in a `collected_files` directory and then compressed into a single `collected_files.zip` archive.

# How to execute

1.  Open PowerShell with administrative privileges.
2.  Navigate to the script directory.
3.  Run the script: `.\collect.ps1`

For detailed, real-time output of the script's actions, use the `-Verbose` flag:

```powershell
.\collect.ps1 -Verbose
```

This will create a file "collected_files.zip" which can be imported into a forensic processing platform such as Cado Response.
