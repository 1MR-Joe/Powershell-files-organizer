# TODO: convert to functions (organizeFiles, logChanges, createUnorganizedFiles)

function New-Unorganized-Directory {
    param (
        [int16]$FileCount,
        [int16]$DirectoryCount,
        [string]$Path
    )

    # TODO: validate FileCount greater than (-gt) 1
    # TODO: validate DirectoryCount greater than or equal (-ge) 0
    # TODO: valitdate Path

    $mainDirectory = $Path + "\unorganized-directory"

    if(Test-Path $mainDirectory) {
        Remove-Item -Path $mainDirectory -Recurse -Force
    }

    New-Item -ItemType Directory -Path $mainDirectory | Out-Null

    $extensions = [string[]]("txt", "jpg", "png", "svg", "pdf", "docx", "pptx", "xlsx")

    $subDirectories = @()

    # create a list of $DirectoryCount directories
    # each element is just the path of that directory
    for ($i = 0; $i -lt $DirectoryCount; $i++) {
        # create directory name
        $subDirectoryName = $mainDirectory + "\Directory-$i"
        
        # append in directories list
        $subDirectories += $subDirectoryName
        
        # or create directory
        New-Item -ItemType Directory -Path $subDirectoryName | Out-Null
    }

    
    if($DirectoryCount -gt 0) {
        # loop over sub directories and create files in them
        $maxFilesInDirectory = [System.Math]::Floor($FileCount / 2)
        $randomCount = Get-Random -Minimum 1 -Maximum $maxFilesInDirectory

        for ($i = 0; $i -lt $subDirectories.Length; $i++) {
            for ($j = 0; $j -lt $randomCount; $j++) {
                $randomExtension = Get-Random -InputObject $extensions
                $newFileName = "file-$j.$randomExtension"
                $newFilePath = $subDirectories[$i] + "\" + $newFileName

                # forcing file creation in case parent directory does not  exist yet
                New-Item -ItemType File -Path $newFilePath -Force | Out-Null

                # track how many files created
                $FileCount--
            }
            #track how many directory created and filled
            $DirectoryCount--
        }
    } 
    
    # this check will evaluate to true either when the user doesn't want sub directories
    # or all sub directories wanted are created but there is some files remaining
    if ($DirectoryCount -eq 0) {
        # create files directly in the main directory
        for ($i = 0; $i -lt $FileCount; $i++) {
            $randomExtension = Get-Random -InputObject $extensions
            $newFileName = "file-$j.$randomExtension"
            $newFilePath = $mainDirectory + "\" + $newFileName
            New-Item -ItemType File -Path $newFilePath | Out-Null
        }
    }
}

# read folder path from user
$folderPath = Read-Host "Enter folder path"

# validate path
if(!(Test-Path $folderPath)) {
    Write-Output "The folder path invalid, please provide a valid one."
    exit # exit the script
}

# hash table that maps each extension to a folder/directory
$extensionToFolder = @{
    ".txt"  = "TextFiles"
    ".jpg"  = "Images"
    ".png"  = "Images"
    ".svg" = "Images"
    ".pdf"  = "Documents"
    ".docx" = "Documents"
    "pptx" = "Documents"
    "xlsx" = "Documents"
}

# create a subfolder for each extension
foreach ($folder in $extensionToFolder.Values | Sort-Object -Unique) {
    $subFolderPath = Join-Path -Path $folderPath -ChildPath $folder
    if (!(Test-Path $subFolderPath)) {
        New-Item -ItemType Directory -Path $subFolderPath | Out-Null
    }
}

# create file for logging
$loggingFile = $folderPath + "\modifications-log.txt"
New-Item -ItemType File -Path $loggingFile

# get the files in current directory | don't print the output
$files = Get-ChildItem -File
$movedFiles = 0

foreach($file in $files) {
    $extension = $file.Extension.ToLower()

    if($extensionToFolder.ContainsKey($extension)) {
        $targetFolder = Join-Path -Path $folderPath -ChildPath $extensionToFolder[$extension]
        Move-Item -Path $file.FullName -Destination $targetFolder -Force
        
        $movedFiles++
        
        # logging
        $modificationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" | Out-Null
        $logMessage = "$modificationDate -> Moved file $($file.Name) to $targetFolder"
        $logMessage | Add-Content -Path $loggingFile
    }
}

# summerize modifications in a message
$finishMessage = "$movedFiles files organized, view modifications-log.txt for more details"

# log message
"$finishMessage $([System.Environment]::NewLine)" | Add-Content -Path $loggingFile

# output message to user
Write-Output $finishMessage