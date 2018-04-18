###############################################
######  Created by: Andrew Constantino  #######
#######          Version 1.1            #######

###############################################
#v1 - base script
#v1.1 - added output for users that have a title, but there is no matching group in CSV.
#       added numbered codes in output to make searching in text file easier.
#       re-worded some output text to make it more clear.
# Note that running this script will pull every user from AD and add them to the approporiate group. 
# In order to run the command Add-ADGroupMember, you will need to run the script as Administrator. 


#imports AD module and writes some lines to the powershell window

Import-Module ActiveDirectory
write-host "`n`n`nPlease select the CSV file"
Write-host "`nPlease be sure you have write access to the folder the CSV file is stored in."
Write-host "Results will be stored in a text file within that folder.`n"
Start-Sleep -Seconds 2

#sets file location for the CSV containing titles and AD Groups
Function Get-FileName($initialDirectory){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null 
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$fileLocation = Get-FileName "C:\temp"

#checks to make sure a valid path was entered for the CSV.
try{
    $folder = Split-Path $FileLocation
}
catch{
    write-host "this is not a valid file"
    break
}

#set some initial variables
$users = ""
$groupsAndTitle = ""

#sets working folder location and filepath for output file.
$folder = Split-Path $fileLocation
$textFile = $folder + "\Compare-Title-to-CSV-Output.txt"
write-host "`n`nWriting output to $textFile"

# Get a list of users in the organization and pull out their username and title
$users = Get-ADUser -filter * -Properties SamAccountName, title
#$users = Get-ADUser -Filter {name -like "*con*"} -Properties SAMAccountName, title

#import the CSV file based on user input file location. Catches invalid files.
try{
    $groupsAndTitle = Import-Csv "$fileLocation"
}

catch{
    write-host "this is not a valid file"
    break
}

#checks how many records in the CSV
$measure = $groupsAndTitle | measure

Add-Content -Path "$textFile" "Code 01: user has no title"
Add-Content -Path "$textFile" "Code 02: user added to a group"
Add-Content -Path "$textFile" "Code 03: non-existent group in AD"
Add-Content -Path "$textFile" "Code 04: title is not paired with group in CSV`n`n"

#for each user in the list of users pulled from AD, find their title and account name.
foreach ($user in $users){
    $title = $user.title
    $name = $user.SamAccountName
    $i = 0

    #Check the title for each user individually againt the list of titles in the CSV.
    #If the title field is empty, stop checking
    #if a match is found in the CSV, add the user the corresponding group. 
    while($i -lt $measure.count){
        if($title -like ""){
            Add-Content -Path "$textFile" "01: user: $name has no title!"
            #write-host "$name - No Title"
            break
            }
			
        else{
            if($title -eq $groupsAndTitle.title[$i]){
            $groupsString = $groupsAndTitle.newdl[$i]
            $Groupcheck = Get-ADGroup -filter {name -like $groupsString} | select Name -ExpandProperty Name
                if ($Groupcheck){
                    try{
                        Add-ADGroupMember -Identity $Groupcheck -Members $name
                        Add-Content -Path "$textFile" "02: ***user: $name was added to group: $GroupsString"
                        Write-Host " ***user: $name was added to group: $GroupsString"
                    } #end try
                    catch{
                        write-host "`n`nerror occurred when attempting to add $name to $groupsString. Try running script as Administrator`n`n "
                        start-sleep -Seconds 1
                        exit
                    } #end catch
                } #end groupcheck if
                else{
                    Add-Content -Path "$textFile" "03: tried adding user: $name to group: $groupsString --but that group does not exist in AD"
                    }#end else
            $i++
            } #end titlecheck if

            else{
                if($i -eq $measure.count-1){
                    Add-Content -Path "$textFile" "04: $name has a title of, $title --but that title is not paired with a group in the CSV."
                    $i++
                    } #end if
                    else{
                    $i++
                    } #end else

            }#end else
            }#end top else
    } #end while
} #end foreach





