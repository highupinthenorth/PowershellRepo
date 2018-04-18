Import-Module activedirectory

function Send-SlackMessage {
    # Add the "Incoming WebHooks" integration to get started: https://slack.com/apps/A0F7XDUAZ-incoming-webhooks
    param (
        [Parameter(Mandatory=$true, Position=0)]$Text,
        $Url="https://hooks.slack.com/services/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", #Put your URL here so you don't have to specify it every time.
        # Parameters below are optional and will fall back to the default setting for the webhook.
        $Username, # Username to send from.
        $Channel, # Channel to post message. Can be in the format "@username" or "#channel"
        $Emoji, # Example: ":bangbang:".
        $IconUrl # Url for an icon to use.
    )

    $body = @{ text=$Text; channel=$Channel; username=$Username; icon_emoji=$Emoji; icon_url=$IconUrl } | ConvertTo-Json
    Invoke-WebRequest -Method Post -Uri $Url -Body $body
}

#$script:users = Get-ADUser -Filter {Name -like "*constan*"} -Properties *| select name -ExpandProperty name
$script:lockedUsers = Search-ADAccount -LockedOut | select SAMAccountName -ExpandProperty SAMAccountName
$currentTime = (get-date).ToString("HHmm")

$emojis = @(
":thumbsup:",
":fire:",
":partydino:",
":partyparrot:",
":cat:",
":nyan-cat:",
":scream_cat:",
":payscalien-scott:",
":unicorn_face:",
":payscalien-mike:",
":partyparrotshuffle:",
":parrotbeer:",
":awyeahhh:",
":epic-sax-guy:",
":heres_johnny:",
":heavy-breathing:",
":ash:",
":awkward_turtle:",
":ayylmao:",
":sad-panda:",
":violin_tiny:",
":tiefighter:",
":grumpy-cat:",
":shipitparrot:",
":shia:",
":shipit:",
":doge:",
":doge3d:",
":donald_trump:",
":doh:",
":dealwithitparrot:",
":business-cat:",
":captainplanet:",
":carlton:",
":dancingpanda:",
":chandler_dance:",
":panda_dance:",
":dancing_corgi:",
":snoop_dancing:",
":parrot_dad:",
":peanut_butter_jelly_time:",
":bueller:",
":badgerbadger:",
":badpundog:",
":cool_beans:",
":bouncytotoro:",
":bob_ross:",
":pusheen-bread:",
":celeryman:",
":chadross:",
":chewbacca:",
":glitch_crab:",
":cthulhu:",
":fire: :bacon:",
":success-kid:",
":kirby:",
":yoga:",
":mojito:",
":mario2:",
":mario:",
":mario1:",
":manatee:",
":jim:",
":hackday:",
":payscale-it:",
":sadparrot:",
":homer-disappear:",
":social_media_dinosaur:",
":beepboop:",
":eazye:",
":elephant:",
":esteban:",
":half-esteban:",
":hear_no_evil:",
":see_no_evil:",
":speak_no_evil:",
":evil:",
":excellent:",
":explodyparrot:",
":facepalm:",
":force-choke:",
":frenchie:",
":icecreamparrot:",
":fiestaparrot:",
":parrotcop:",
":skiparrot:",
":data-corn:",
":sonic:",
":toof_is_sad:",
":unicorn_face:",
":fix-it_felix:",
":fidget:",
":george:",
":glitch_crab:",
":glowstick:",
":goat:",
":goomba:",
":no-good:",
":grimacing:",
":guinea-pig:",
":hamburgler:",
":hahabusiness:",
":hammer_time:",
":hadouken:",
":hali:",
":spock-hand:",
":hulkhogan:",
":idaho:",
":itslit:",
":jarjarbinks:",
":kanye:",
":koala:",
":krabby:",
":la-croix-grapefruit:",
":la-croix-lemon:",
":la-croix-lime:",
":letsplay:",
":t-rex-team-left:",
":lit:",
":lumberg:",
":pineapple:",
":thonkingggg:",
":totoro:",
":totorohoop:", 
":waiting:",
":adam:",
":black-disco-ball:",
":buggy:",
":dat-boi:",
":deathstar2:", 
":angry_trump:", 
":autobots:", 
":aww-yiss:",
":babypanther:",
":bender:",
":bernie_sanders:",
":betterghost:",
":bettlejuice:",
":binary:",
":bitcoin:",
":black-disco-ball:",
":black_panther:",
":blueranger:",
":boris:",
":bye_boo:",
":cage:",
":captainamerica:",
":car-t-rex:",
":car-team:",
":cassidy:",
":chili:",
":consumer_marketing:",
":corgi:",
":covfefe:",
":cry_rainbow_tears:",
":cubone:",
":curling:",
":data-corn:",
":data-science:",
":dead:",
":donatello:",
":donkey:",
":drevil:",
":dumpsterfire:",
":dumpling_bun:",
":fiestiaparrot:",
":fist-shake:",
":flamingo:",
":flipflop:",
":frenchie:",
":fsm:",
":garret:",
":george:",
":great_lakes:",
":greatsuccess:",
":greenman:",
":grooming:",
":grumpybaby:",
":guitarcenter:",
":hali:",
":hillary_clinton:",
":hodor:",
":hypno_spiral:",
":insightdown:",
":java:",
":left_shark:",
":limabean:",
":mac:",
":mary-jane:",
":megaman:",
":monkeyy:",
":moose:",
":ms:",
":mysterymachine:"

)
$emojiLength = $emojis.length-1
#$currentEmoji = ":payscale-it:"

function checkTime{
if($currentTime -eq "0600"){
Send-SlackMessage "Goodmorning Payscale IT" -Channel "#account-lockouts"
}
if($currentTime -eq "1905"){
Send-SlackMessage "Goodnight" -Channel "#account-lockouts"
}
else{
}
}

function checkLocked{
if($script:lockedUsers){
    foreach($user in $script:lockedUsers){
        if(test-path "\\filer02\IT\zz_aconstantino\LockedOutFiles\$user.txt"){
            $lockTime = gc "\\filer02\IT\zz_aconstantino\LockedOutFiles\$user.txt"
            $checkTime = (get-date).AddMinutes(-9).ToString("HHmm")
                if(($lockTime -lt $checkTime) -and ($checkTime % 13 -eq 0)){
                    if($locktime -gt "1259"){
                        $twelveHourLockTime = $locktime - 1200
                        $string = $twelveHourLockTime.ToString()
                        $writeTime = $string[0]+":"+$string[1]+$string[2]
                        Send-SlackMessage "$user is still locked out! -- $writeTime" -Channel "#account-lockouts"
                        }
                    if(($locktime -le "1259") -and ($locktime -gt "0959")){
                        $string = $lockTime.ToString()
                        $writeTime = $string[0]+$string[1]+":"+$string[2]+$string[3]
                        Send-SlackMessage "$user is still locked out! -- $writeTime" -Channel "#account-lockouts"
                        }
                    if(($lockTime -gt "0559") -and ($lockTime -le "0959")){
                        $string = $lockTime.ToString()
                        $writeTime = $string[1]+":"+$string[2]+$string[3]
                        Send-SlackMessage "$user is still locked out! -- $writeTime" -Channel "#account-lockouts"
                        }
                        else{
                        #Send-SlackMessage "In the Else and you shouldn't be -- Locktime: $locktime" -Channel "#account-lockouts"
                        }
                } #end check time if
                else{
                }
            } #end test if

        else{
            $log = Get-EventLog -computername HQAD03 -LogName Security -InstanceId 4740 -Message "*$user*" -Newest 1 | fl -Property Message | out-string
            $computer = ($log -split "Name",4)[3]
            $count = $computer | measure -Character -IgnoreWhiteSpace | select Characters -ExpandProperty characters
            
            #$pos = $log.IndexOf("Name",420)
            #$right = $log.substring($pos+1)
            #$computer = $right -replace '\s',''
            $i = Get-Random -Minimum 0 -Maximum $emojiLength
            $emoji = $emojis[$i]
            Out-File -FilePath "\\filer02\IT\zz_aconstantino\LockedOutFiles\$user.txt" -InputObject $currentTime
                if(($computer -eq ":") -or ($computer -eq $null) -or ($count -eq 1)){
                    Send-SlackMessage "$user is locked out! $emoji -- No machine name in event log" -Channel "#account-lockouts"
                    #Send-SlackMessage "$user is locked out! $currentEmoji -- No machine name in event log" -Channel "#account-lockouts"
                    }
                    else{
                    Send-SlackMessage "$user is locked out! $emoji -- Check machine name$computer" -Channel "#account-lockouts"
                    #Send-SlackMessage "$user is locked out! $currentEmoji -- Check machine n$computer" -Channel "#account-lockouts"
                    }
            }#end else
        } #end foreach
}

else{
Remove-Item "\\filer02\IT\zz_aconstantino\LockedOutFiles\*"

}
}

checkTime
checkLocked