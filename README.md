# Remove-LeadingSpaces

PowerShell script that safely removes leading spaces from file and folder names recursively. Features WhatIf preview mode, confirmation prompts, conflict detection, and detailed logging. All operations are logged with timestamps for auditing.

## Remove-LeadingSpaces.ps1

### Usage

```powershell
.\Remove-LeadingSpaces.ps1 -Path "C:\YourFolder" [-WhatIf]
```

### Features

- Safe recursive renaming of files and folders
- Preview mode with -WhatIf parameter
- Confirmation prompts before changes
- Conflict detection
- Detailed timestamped logging
- Processes directories before their contents
- PowerShell 5.1+ required

### Examples

```powershell
# Preview changes
.\Remove-LeadingSpaces.ps1 -Path "C:\Users\Documents" -WhatIf

# Remove leading spaces
.\Remove-LeadingSpaces.ps1 -Path "D:\Photos"
```

### Logging

Operations are logged to `C:\Temp\Remove-LeadingSpaces_[timestamp].log`

## Create-TestFiles.ps1

A companion script for testing `Remove-LeadingSpaces.ps1`. Creates a test environment with random files and folders, some of which have leading spaces.

### Usage

```powershell
.\Create-TestFiles.ps1 -Path "C:\TestArea" [-FileCount 20] [-FolderCount 10]
```

### Features

- Creates files with random realistic names
- Generates a mix of files with and without leading spaces
- Supports multiple file extensions (.txt, .doc, .pdf, .jpg, .png)
- Creates nested folder structure for thorough testing
- Customizable number of files and folders

### Parameters

- `-Path`: Target directory for test files (required)
- `-FileCount`: Number of files to create (default: 10)
- `-FolderCount`: Number of folders to create (default: 5)

### Example

```powershell
# Create 20 files and 10 folders with random names
.\Create-TestFiles.ps1 -Path "C:\TestArea" -FileCount 20 -FolderCount 10

# Use default counts (10 files, 5 folders)
.\Create-TestFiles.ps1 -Path "C:\TestArea"
```

## Requirements

- PowerShell 5.1 or later
- Write access to target directories
- Write access to C:\Temp for logging