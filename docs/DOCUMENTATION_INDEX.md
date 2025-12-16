# Host Evidence Runner (HER) - Documentation Index

**Last Updated:** December 15, 2025  
**Version:** 1.0.0

Navigate HER documentation by your role and current task.

---

## 🎯 Quick Navigation by Role

### For System Administrators

**Running the collection tool:**
1. [`docs/sysadmin/QUICK_START.txt`](sysadmin/QUICK_START.txt) - 1-page quick guide ⭐ **START HERE**
2. [`docs/sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md`](sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md) - Complete deployment guide with troubleshooting

### For Forensic Analysts

**Planning & Deployment:**
1. [`docs/analyst/ANALYST_DEPLOYMENT_CHECKLIST.md`](analyst/ANALYST_DEPLOYMENT_CHECKLIST.md) - Pre/during/post deployment ⭐ **START HERE**
2. [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md) - Architecture, logging, error handling
3. [`docs/analyst/WINDOWS_SERVER_FORENSICS_PLAN.md`](analyst/WINDOWS_SERVER_FORENSICS_PLAN.md) - Complete artifact reference

**Analysis & Investigation:**
1. [`docs/PHASE_2_TESTING_GUIDE.md`](PHASE_2_TESTING_GUIDE.md) - Analysis workflows and validation
2. [`docs/PHASE_2_TOOLS_INSTALLATION.md`](PHASE_2_TOOLS_INSTALLATION.md) - Installing Zimmerman tools, Yara
3. [`docs/INVESTIGATION_RESULTS_STRUCTURE.md`](INVESTIGATION_RESULTS_STRUCTURE.md) - Understanding output structure

### For Everyone

**Quick References:**
- [`docs/reference/QUICK_START.md`](reference/QUICK_START.md) - Quick start for various scenarios
- [`docs/reference/QUICK_REFERENCE.md`](reference/QUICK_REFERENCE.md) - Command reference and examples
- [`00_START_HERE.md`](../00_START_HERE.md) - Project overview and navigation
- [`README.md`](../README.md) - Main project documentation with data sources table

---

## 📚 Complete Document List

### Core Documentation

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| **[`00_START_HERE.md`](../00_START_HERE.md)** | All | Project overview, navigation | 5 min |
| **[`README.md`](../README.md)** | All | Main documentation, data sources collected | 15 min |
| **[`LICENSE`](../LICENSE)** | All | Apache 2.0 license terms | 2 min |

### Collection Phase

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| [`run-collector.ps1`](../run-collector.ps1) | Analyst/Sysadmin | Main collection launcher | - |
| [`RUN_COLLECT.bat`](../RUN_COLLECT.bat) | Sysadmin | Batch launcher for restricted environments | - |
| [`source/collect.ps1`](../source/collect.ps1) | Developer | Core collection engine (source code) | - |
| [`docs/sysadmin/QUICK_START.txt`](sysadmin/QUICK_START.txt) | Sysadmin | 1-page deployment guide | 2 min |
| [`docs/sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md`](sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md) | Sysadmin | Complete deployment with FAQ | 10 min |

### Analysis Phase

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| [`source/Analyze-Investigation.ps1`](../source/Analyze-Investigation.ps1) | Analyst | Analysis engine with multiple modules | - |
| [`modules/CadoBatchAnalysis/`](../modules/CadoBatchAnalysis/) | Developer | PowerShell analysis module | - |
| [`docs/PHASE_2_TESTING_GUIDE.md`](PHASE_2_TESTING_GUIDE.md) | Analyst | Analysis workflow and validation | 20 min |
| [`docs/PHASE_2_TOOLS_INSTALLATION.md`](PHASE_2_TOOLS_INSTALLATION.md) | Analyst | Installing analysis tools | 15 min |
| [`docs/INVESTIGATION_RESULTS_STRUCTURE.md`](INVESTIGATION_RESULTS_STRUCTURE.md) | Analyst | Output structure reference | 10 min |

### Technical Reference

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md) | Analyst | Architecture, logging, troubleshooting | 30 min |
| [`docs/analyst/WINDOWS_SERVER_FORENSICS_PLAN.md`](analyst/WINDOWS_SERVER_FORENSICS_PLAN.md) | Analyst | Complete artifact inventory by role | 30 min |
| [`docs/analyst/BINS_EVALUATION_AND_TOOLS.md`](analyst/BINS_EVALUATION_AND_TOOLS.md) | Developer | Tool evaluation and selection | 20 min |
| [`docs/analyst/CADO_HOST_ANALYSIS_AND_RECOMMENDATIONS.md`](analyst/CADO_HOST_ANALYSIS_AND_RECOMMENDATIONS.md) | Analyst | Cado platform integration | 15 min |

### Planning & Deployment

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| [`docs/analyst/ANALYST_DEPLOYMENT_CHECKLIST.md`](analyst/ANALYST_DEPLOYMENT_CHECKLIST.md) | Analyst | Comprehensive deployment checklist | 15 min |
| [`source/deploy_multi_server.ps1`](../source/deploy_multi_server.ps1) | Analyst | Multi-host deployment script | - |

### Quick References

| Document | Audience | Purpose | Time |
|----------|----------|---------|------|
| [`docs/reference/QUICK_START.md`](reference/QUICK_START.md) | All | Quick start guide with examples | 10 min |
| [`docs/reference/QUICK_REFERENCE.md`](reference/QUICK_REFERENCE.md) | All | Command reference and workflows | 10 min |

---

## 🔍 Find Documentation by Task

### "I need to collect evidence from a server"

**For Sysadmin:**
1. Read [`docs/sysadmin/QUICK_START.txt`](sysadmin/QUICK_START.txt) (2 minutes)
2. Copy HER folder to USB
3. Run `run-collector.ps1` as Administrator on target
4. Return USB with `investigations/` folder

**For Analyst (planning):**
1. Review [`docs/analyst/ANALYST_DEPLOYMENT_CHECKLIST.md`](analyst/ANALYST_DEPLOYMENT_CHECKLIST.md)
2. Prepare USB and documentation
3. Coordinate with sysadmin

### "I need to analyze collected evidence"

1. **Install tools:** [`docs/PHASE_2_TOOLS_INSTALLATION.md`](PHASE_2_TOOLS_INSTALLATION.md)
2. **Review workflow:** [`docs/PHASE_2_TESTING_GUIDE.md`](PHASE_2_TESTING_GUIDE.md)
3. **Run analysis:**
   ```powershell
   .\source\Analyze-Investigation.ps1 -InvestigationPath ".\investigations\Case\Host\20251215" -FullAnalysis
   ```
4. **Review results:** Output in `Phase3_*` folders

### "I need to deploy to multiple servers"

1. **Plan:** [`docs/analyst/ANALYST_DEPLOYMENT_CHECKLIST.md`](analyst/ANALYST_DEPLOYMENT_CHECKLIST.md)
2. **Prepare:** Create server list, test credentials
3. **Execute:**
   ```powershell
   .\source\deploy_multi_server.ps1 -InvestigationName "Case123" -Targets "Server01","Server02","DC01"
   ```
4. **Review:** Deployment report in `investigations/Case123/`

### "I need to understand what data is collected"

1. **Quick overview:** [`README.md`](../README.md) - "Data Sources Collected" section
2. **Detailed reference:** [`docs/analyst/WINDOWS_SERVER_FORENSICS_PLAN.md`](analyst/WINDOWS_SERVER_FORENSICS_PLAN.md)
3. **Output structure:** [`docs/INVESTIGATION_RESULTS_STRUCTURE.md`](INVESTIGATION_RESULTS_STRUCTURE.md)
4. **Source code:** [`source/collect.ps1`](../source/collect.ps1)

### "I'm troubleshooting a collection issue"

1. **Check logs:** `investigations/<host>/<timestamp>/forensic_collection_*.txt`
2. **Review summary:** `investigations/<host>/<timestamp>/COLLECTION_SUMMARY.txt`
3. **Error reference:** [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md) - Error Handling section
4. **Sysadmin FAQ:** [`docs/sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md`](sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md) - Troubleshooting section

### "I need to customize the collection"

1. **Understand architecture:** [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md)
2. **Review source:** [`source/collect.ps1`](../source/collect.ps1)
3. **Test changes:** On non-production system
4. **Update docs:** Document custom modifications

---

## 📖 Recommended Reading Order

### For First-Time Analysts

1. [`00_START_HERE.md`](../00_START_HERE.md) - 5 minutes
2. [`README.md`](../README.md) - 15 minutes (focus on Data Sources table)
3. [`docs/analyst/ANALYST_DEPLOYMENT_CHECKLIST.md`](analyst/ANALYST_DEPLOYMENT_CHECKLIST.md) - 15 minutes
4. [`docs/analyst/WINDOWS_SERVER_FORENSICS_PLAN.md`](analyst/WINDOWS_SERVER_FORENSICS_PLAN.md) - 30 minutes
5. [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md) - 30 minutes

**Total:** ~95 minutes to become proficient

### For First-Time Sysadmins

1. [`docs/sysadmin/QUICK_START.txt`](sysadmin/QUICK_START.txt) - 2 minutes
2. [`docs/sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md`](sysadmin/SYSADMIN_DEPLOYMENT_GUIDE.md) - 10 minutes

**Total:** ~12 minutes to deploy successfully

### For Developers Contributing

1. [`00_START_HERE.md`](../00_START_HERE.md) - 5 minutes
2. [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md) - 30 minutes
3. [`source/collect.ps1`](../source/collect.ps1) - Code review (30-60 minutes)
4. [`modules/CadoBatchAnalysis/CadoBatchAnalysis.psm1`](../modules/CadoBatchAnalysis/CadoBatchAnalysis.psm1) - Module review

**Total:** ~90 minutes + code review time

---

## 🗂️ Archive

Historical documents from project development phases are in [`archive/`](../archive/):

- Phase 1 & 2 implementation summaries
- Original project context and planning
- Legacy README versions
- Development milestone documents

These are kept for reference but superseded by current documentation.

---

## 🆘 Need Help?

**Can't find what you need?**

1. **Check this index** for related documents
2. **Search [`README.md`](../README.md)** for keywords
3. **Review collection logs** in `investigations/` for troubleshooting
4. **Consult [`docs/analyst/TECHNICAL_DOCUMENTATION.md`](analyst/TECHNICAL_DOCUMENTATION.md)** for technical details

**Found an issue or have suggestions?**

- Document unclear? Update it with clarifications
- Missing documentation? Create new guide
- Found a bug? Check logs and report details

---

## 📊 Documentation Statistics

- **Total Documents:** 20+ files
- **For Sysadmins:** 2 documents (~12 min reading)
- **For Analysts:** 10+ documents (~3 hours comprehensive reading)
- **Quick References:** 4 documents (~30 min reading)
- **Archive:** 14+ historical documents

---

**Maintained By:** Host Evidence Runner (HER) Project  
**Last Updated:** December 15, 2025  
**Documentation Version:** 1.0.0
