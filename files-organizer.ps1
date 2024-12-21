# importing helper file
. C:\Users\divos\Desktop\files-organizer\files-organizer-helper.ps1

# read folder path from user
[String] $mainDirectory = Read-Host "Enter folder path"
# validate path
if(!(Test-Path $mainDirectory)) {
    Write-Output "The folder path invalid, please provide a valid one."
    exit # exit the script
}

[String[]] $directories = @($mainDirectory)

[String] $organizeSubDirectories = (Read-Host("Do you want to organize sub directories? (yes/no)")).ToLower()

if ($organizeSubDirectories.Length -gt 0 -and $organizeSubDirectories[0] -eq "y") {
    $subDirectories = Get-ChildItem -Directory -Path $mainDirectory
    
    foreach ($dir in $subDirectories) {
        $directories += $dir.FullName
    }
}

# list of directories (strings)
# if the user want to organize sub directories
# then get all sub directories in the directories list + the main directory
# that the user want to organize
# pass this list to the function, and that's it

# hash table that maps each extension to a folder/directory
$extensionToDir = @{
    ".txt"  = "TextFiles"
    ".jpg"  = "Images"
    ".png"  = "Images"
    ".svg" = "Images"
    ".pdf"  = "Documents"
    ".docx" = "Documents"
    ".pptx" = "Documents"
    ".xlsx" = "Documents"
}

# organize files
$movedFiles = Organize-Files -Directories $directories -ExtensionToDir $extensionToDir

# output message to user
Write-Output("$movedFiles files organized, view modifications-log.txt for more details")