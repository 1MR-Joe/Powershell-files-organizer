function Move-File-Handle-Duplicates {
    param (
        [System.IO.FileInfo] $File,
        [string] $TargetDirectory
    )

    # TODO: validate $TargetDirectory exists

    $testFilePath = Join-Path -Path $TargetDirectory -ChildPath $File.Name
    if(Test-Path $testFilePath) {
        # file exists, and "this" file is a duplicate, mark the duplicate as a copy
        $newFileName = [System.IO.Path]::GetFileNameWithoutExtension($File) + "_copy" + $File.Extension
        $newFilePath = Join-Path -Path $TargetDirectory -ChildPath $newFileName
        Move-Item -Path $File.FullName -Destination $newFilePath -Force
    } else {
        # this file is not a duplicate of another file
        Move-Item -Path $File.FullName -Destination $TargetDirectory -Force
    }
}

function New-Extension-Specific-Subdirectories {
    param (
        [String] $MainDirectory,
        [hashtable] $ExtensionToDir
    )

    # TODO: validate $MainDirectory exists

    foreach ($dir in $ExtensionToDir.Values | Sort-Object -Unique) {
        $subDirPath = Join-Path -Path $MainDirectory -ChildPath $dir
        if (!(Test-Path $subDirPath)) {
            New-Item -ItemType Directory -Path $subDirPath | Out-Null
        }
    }
}

function Log-Modification {
    param (
        [System.IO.FileInfo] $File,
        [String] $TargetDirectory,
        [String] $LoggingFile
    )

    # TODO: validate $LoggingFile exists
    $modificationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$modificationDate -> Moved file $($file.Name) to $targetDirectory"
    $logMessage | Add-Content -Path $loggingFile
}

# function returns integer, can't mark the return type since powershell version is 5 instead of 7 :(
function Organize-Files {
    param (
        [String[]] $Directories,
        [hashtable] $ExtensionToDir
    )

    # TODO: validate $MainDirectory

    $movedFilesAll = 0

    # main modification loop
    foreach($dir in $Directories) {
        Write-Output "orginazing directory $dir $([System.Environment]::NewLine)"

        # variable for tracking moved files per directory
        $movedFilesPerDir = 0

        # create a sub directory for each extension
        New-Extension-Specific-Subdirectories -MainDirectory $dir -ExtensionToDir $ExtensionToDir
        
        # get files in directory
        [System.IO.FileInfo[]] $files = Get-ChildItem -File -Path $dir

        # create a log file to log modifications in it
        $loggingFile = Join-Path -Path $dir -ChildPath "modifications-log.txt"
        if(!(Test-Path $loggingFile)) {
            New-Item -ItemType File -Path $loggingFile | Out-Null
        }

        foreach($file in $files) {
            $extension = $file.Extension.ToLower()
    
            if($ExtensionToDir.ContainsKey($extension)) {
                $targetDirectory = Join-Path -Path $dir -ChildPath $ExtensionToDir[$extension]
                Move-File-Handle-Duplicates -File $file -TargetDirectory $targetDirectory
    
                # tracking modifications
                $movedFilesAll++
                $movedFilesPerDir++
                
                # logging
                Log-Modification -File $file -TargetDirectory $targetDirectory -LoggingFile $loggingFile
            }
        }

        # Log finish message
        $finishMessage = "$movedFilesPerDir files organized"
        "$finishMessage $([System.Environment]::NewLine)" | Add-Content -Path $loggingFile
    }

    return $movedFilesAll
}