<#
.SYNOPSIS
    Creates random files and folders with some having leading spaces.

.DESCRIPTION
    This script creates a specified number of random files and folders in a target directory.
    Approximately half of the created items will have leading spaces in their names.
    This is useful for testing the Remove-LeadingSpaces.ps1 script.

.PARAMETER Path
    The directory where the test files and folders will be created.

.PARAMETER FileCount
    Number of files to create. Default is 10.

.PARAMETER FolderCount
    Number of folders to create. Default is 5.

.EXAMPLE
    .\Create-TestFiles.ps1 -Path "C:\TestArea" -FileCount 20 -FolderCount 10
    Creates 20 files and 10 folders in C:\TestArea with random names.
#>

param(
    [Parameter(Mandatory=$true,
               Position=0,
               HelpMessage="Enter the path where test files should be created")]
    [string]$Path,

    [Parameter(Mandatory=$false,
               HelpMessage="Number of files to create")]
    [int]$FileCount = 10,

    [Parameter(Mandatory=$false,
               HelpMessage="Number of folders to create")]
    [int]$FolderCount = 5
)

# Array of possible file extensions
$extensions = @('.txt', '.doc', '.pdf', '.jpg', '.png')

# Array of possible word components to create somewhat realistic names
$wordComponents = @(
    'Report', 'Document', 'Photo', 'Image', 'Project',
    'Meeting', 'Notes', 'Draft', 'Final', 'Backup',
    'Archive', 'Data', 'Summary', 'Review', 'Analysis'
)

# Function to generate a random filename
function Get-RandomName {
    param(
        [switch]$IsFolder
    )
    
    # 50% chance of adding a leading space
    $leadingSpace = (Get-Random -Minimum 0 -Maximum 2) -eq 1 ? " " : ""
    
    # Generate 1-3 random components
    $componentCount = Get-Random -Minimum 1 -Maximum 4
    $nameComponents = @()
    
    for ($i = 0; $i -lt $componentCount; $i++) {
        $nameComponents += $wordComponents | Get-Random
    }
    
    $baseName = $leadingSpace + ($nameComponents -join "_")
    
    if ($IsFolder) {
        return $baseName
    }
    else {
        # Add random number and extension
        $number = Get-Random -Minimum 1 -Maximum 1000
        $extension = $extensions | Get-Random
        return "${baseName}_${number}${extension}"
    }
}

# Ensure target directory exists
if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
    Write-Host "Created directory: $Path"
}

# Create random folders
Write-Host "`nCreating $FolderCount folders..."
for ($i = 1; $i -le $FolderCount; $i++) {
    $folderName = Get-RandomName -IsFolder
    $folderPath = Join-Path $Path $folderName
    
    try {
        New-Item -ItemType Directory -Path $folderPath | Out-Null
        Write-Host "Created folder: '$folderName'"
    }
    catch {
        Write-Warning "Failed to create folder '$folderName': $_"
    }
}

# Create random files
Write-Host "`nCreating $FileCount files..."
for ($i = 1; $i -le $FileCount; $i++) {
    $fileName = Get-RandomName
    $filePath = Join-Path $Path $fileName
    
    try {
        New-Item -ItemType File -Path $filePath | Out-Null
        Write-Host "Created file: '$fileName'"
    }
    catch {
        Write-Warning "Failed to create file '$fileName': $_"
    }
}

# Create some files in the subfolders as well
Write-Host "`nAdding some files to random subfolders..."
$folders = Get-ChildItem -Path $Path -Directory
foreach ($folder in $folders) {
    # Add 1-3 files to each folder
    $subFileCount = Get-Random -Minimum 1 -Maximum 4
    
    for ($i = 1; $i -le $subFileCount; $i++) {
        $fileName = Get-RandomName
        $filePath = Join-Path $folder.FullName $fileName
        
        try {
            New-Item -ItemType File -Path $filePath | Out-Null
            Write-Host "Created file in subfolder: '$($folder.Name)\$fileName'"
        }
        catch {
            Write-Warning "Failed to create file in subfolder '$($folder.Name)\$fileName': $_"
        }
    }
}

Write-Host "`nCreation completed!"
Write-Host "Total items created:"
Write-Host "- $FolderCount folders"
Write-Host "- $FileCount files in root directory"
Write-Host "- Additional files in subfolders"
Write-Host "`nYou can now test Remove-LeadingSpaces.ps1 on this directory."