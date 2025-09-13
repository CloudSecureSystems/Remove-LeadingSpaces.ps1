# Remove-LeadingSpaces

PowerShell script that safely removes leading spaces from file and folder names recursively. Features WhatIf preview mode, confirmation prompts, conflict detection, and detailed logging. All operations are logged with timestamps for auditing.

## Usage

```powershell
.\Remove-LeadingSpaces.ps1 -Path "C:\YourFolder" [-WhatIf]
```

## Features

- Safe recursive renaming of files and folders
- Preview mode with -WhatIf parameter
- Confirmation prompts before changes
- Conflict detection
- Detailed timestamped logging
- Processes directories before their contents
- PowerShell 5.1+ required

## Examples

```powershell
# Preview changes
.\Remove-LeadingSpaces.ps1 -Path "C:\Users\Documents" -WhatIf

# Remove leading spaces
.\Remove-LeadingSpaces.ps1 -Path "D:\Photos"
```

## Logging

Operations are logged to `C:\Temp\SpaceRemoval_[timestamp].log`