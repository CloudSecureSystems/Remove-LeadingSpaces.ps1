#Requires -Version 5.1
<#
.SYNOPSIS
    Removes leading spaces from file and folder names in a specified directory.

.DESCRIPTION
    This PowerShell script identifies and removes leading spaces from file and folder names
    in a specified directory and its subdirectories. It includes comprehensive logging and
    safety features such as WhatIf preview mode and confirmation prompts.

.PARAMETER Path
    The directory path to scan for files and folders with leading spaces.
    This parameter is mandatory.

.PARAMETER WhatIf
    If specified, shows what changes would be made without actually making them.
    Useful for previewing the operations that would be performed.

.EXAMPLE
    .\Remove-LeadingSpaces.ps1 -Path "C:\Users\Documents"
    Scans the Documents folder for items with leading spaces and prompts for confirmation before removing them.

.EXAMPLE
    .\Remove-LeadingSpaces.ps1 -Path "D:\Photos" -WhatIf
    Shows what changes would be made to files in the Photos folder without actually renaming anything.

.NOTES
    Author: GitHub Copilot
    Date: September 2025
    Version: 2.0
    
    All operations are logged to C:\Temp with timestamps for audit purposes.
    The script will create the log directory if it doesn't exist.
#>

param(
    [Parameter(Mandatory=$true,
               Position=0,
               HelpMessage="Enter the path to scan for files/folders with leading spaces")]
    [ValidateScript({Test-Path $_})]
    [string]$Path,
    
    [Parameter(Mandatory=$false,
               HelpMessage="Specify to preview changes without making them")]
    [switch]$WhatIf
)

# Initialize logging infrastructure
$logDir = "C:\Temp"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Create a timestamped log file for this operation
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logDir "SpaceRemoval_$timestamp.log"
"Space Removal Operation Log - Started at $(Get-Date)" | Out-File $logFile

function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Host $logMessage
    $logMessage | Out-File $logFile -Append
}

function Find-ItemsWithLeadingSpace {
    param($SearchPath)
    Write-Log "Scanning directory: $SearchPath"
    try {
        $items = Get-ChildItem -Path $SearchPath -Recurse -ErrorAction Stop | 
                Where-Object { $_.Name -match '^ ' }
        return $items
    }
    catch {
        Write-Log "ERROR: Failed to scan directory: $_"
        return @()
    }
}

function Remove-LeadingSpace {
    param(
        $Item,
        [switch]$WhatIf
    )
    try {
        # Generate new name by removing all leading spaces
        $newName = $Item.Name -replace '^ +', ''
        
        # For files, use the current parent directory (which may have been renamed)
        $currentParent = Split-Path -Path $Item.FullName -Parent
        $newPath = Join-Path -Path $currentParent -ChildPath $newName
        
        # Check if target already exists
        if (Test-Path -LiteralPath $newPath) {
            Write-Log "WARNING: Cannot rename '$($Item.FullName)' - target '$newPath' already exists"
            return $false
        }
        
        if ($WhatIf) {
            Write-Log "WHATIF: Would rename '$($Item.FullName)' to '$newPath'"
            return $true
        }
        else {
            Write-Log "Renaming: '$($Item.FullName)' to '$newPath'"
            Rename-Item -LiteralPath $Item.FullName -NewName $newName -ErrorAction Stop
            Write-Log "Successfully renamed item"
            return $true
        }
    }
    catch {
        Write-Log "ERROR: Failed to rename '$($Item.FullName)': $_"
        return $false
    }
}

# Validate path
if (-not (Test-Path $Path)) {
    Write-Log "ERROR: Path '$Path' does not exist"
    exit 1
}

# Find items with leading spaces
Write-Log "Starting scan for items with leading spaces..."
$items = @(Find-ItemsWithLeadingSpace -SearchPath $Path)

if ($items.Count -eq 0) {
    Write-Log "No items found with leading spaces."
    exit 0
}

Write-Log "Found $($items.Count) items with leading spaces:"
$items | ForEach-Object { Write-Log "  $($_.FullName)" }

# If not in WhatIf mode, prompt for confirmation
if (-not $WhatIf) {
    $confirmation = Read-Host "`nDo you want to remove leading spaces from these items? (Y/N)"
    if ($confirmation -ne 'Y') {
        Write-Log "Operation cancelled by user"
        exit 0
    }
}

# Sort items to process directories first, and from shortest path to longest
# This ensures parent directories are renamed before their contents
$sortedItems = $items | Sort-Object -Property @{
    Expression = { ($_.FullName -split '\\').Count }
}, @{
    Expression = { $_.PSIsContainer -eq $false }
}, FullName

# Process items
$successCount = 0
foreach ($item in $sortedItems) {
    # Refresh item to get current path
    try {
        if (Test-Path -LiteralPath $item.FullName) {
            $currentItem = Get-Item -LiteralPath $item.FullName
            if (Remove-LeadingSpace -Item $currentItem -WhatIf:$WhatIf) {
                $successCount++
            }
        }
    }
    catch {
        Write-Log "ERROR: Failed to process item '$($item.FullName)': $_"
    }
}

# Summary
Write-Log "`nOperation completed:"
Write-Log "Total items processed: $($items.Count)"
Write-Log "Successful operations: $successCount"
Write-Log "Log file location: $logFile"