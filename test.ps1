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

New-Unorganized-Directory -FileCount 10 -DirectoryCount 2 -Path ~\Desktop