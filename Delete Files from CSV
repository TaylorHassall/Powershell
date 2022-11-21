<#

.SYNOPSIS
  Powershell script to delete files based off ab imported CSV
  
.DESCRIPTION
  The script will take an cmd line argument of the CSV you wish
  to import. Once imported it will iterate through the items in
  the column. For each one of those items, it converts it to an
  object to allow CSV Export.
  
.PARAMETER <path>
   Directory path of the files to check. If this parameter is not
   specified the default value is current directory. Ensure you 
   wrap the path in double quotes if 
 
.NOTES
  Version:        1.0
  Author:         Taylor Hassall
  Creation Date:  09-11-2022
  Last Modified:  09-11-2022
 
.LINK
    N/A
    
.EXAMPLE
  .\DeleteStubs.ps1 "C:\Users\username\Script\DeleteStubs\TestFiles.csv"
  .\DeleteStubs.ps1 .\TestFiles.csv

#>

Start-Transcript 
#$args0 allows cmdline arguments
$Csvpath=$args[0]
#Logs and transcribes the CSV imported to delete
Write-Host -ForegroundColor Yellow "Importing $Csvpath as list of files to remove"
#Wait to allow the user to see the imported CSV
start-sleep -seconds 4

Import-csv -path $Csvpath | Foreach-Object{
    #Sets the FullPath Variable with the current pipes object which is the path imported from the CSV

    $fullpath = $_.FilePathName
    #Write the host to confirm which file is in the pipe. Mostly a debugging/monitoring feature
    Write-Host "Attempting to delete $FullPath"
    #Create a new Object with the member property of the $fullpath. This converts it to an object instead of a string. When Exporting as a string it will only have one Value (Length). This created a value of "FilePath" which can be xported.
    $obj = New-Object PSObject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "FilePath" -Value $fullpath
    #Remove the item in the Pipe.
    remove-item -Path $fullpath -Force
    #Check the Path we're deleting. Test Path with return True if the file still exists, false if it fails.
    $FileStatus = Test-Path -path $fullpath
    #If $Filestatus is True (File still exists), report as failure, otherwise success.
    if ($filestatus) {
        Write-Host "File $FullPath was unable to be, or was not deleted."
        $obj | export-csv "C:\Temp\StudDelete\StudDeleteFailure.csv" -append
    }else{
        Write-Host "File $_.FilePathName was deleted."
        $obj | Export-CSv "C:\Temp\StudDelete\StudDeleteSuccess.csv" -append
        }
}
