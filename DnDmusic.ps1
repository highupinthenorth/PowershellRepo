#################################################
###########       Dependencies     ##############

#You must have internet explorer installed.
#You must have the adblock extension installed for IE to avoid ads for youtube.
#You must be ready to rock.


##################################################



Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    // f(), g(), ... are unused COM method slots. Define these if you care
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f(); // Unused
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
}
'@


$volumeUp = "
[audio]::Volume  = 0.1
start-sleep -m 100
[audio]::Volume  = 0.2
start-sleep -m 100
[audio]::Volume  = 0.3
start-sleep -m 150
[audio]::Volume  = 0.4
start-sleep -m 150
[audio]::Volume  = 0.5
start-sleep -m 200
[audio]::Volume  = 0.6
start-sleep -m 200
[audio]::Volume  = 0.7
start-sleep -m 250
[audio]::Volume  = 0.8
start-sleep -m 250
[audio]::Volume  = 0.9"

$volumeDown = "
[audio]::Volume  = 0.9
start-sleep -m 250
[audio]::Volume  = 0.8
start-sleep -m 250
[audio]::Volume  = 0.7
start-sleep -m 150
[audio]::Volume  = 0.6
start-sleep -m 150
[audio]::Volume  = 0.5
start-sleep -m 150
[audio]::Volume  = 0.4
start-sleep -m 100
[audio]::Volume  = 0.3
start-sleep -m 100
[audio]::Volume  = 0.2
start-sleep -m 100
[audio]::Volume  = 0.1
"

#these are up-beat songs that are for fighting
$script:fightlist = New-Object System.Collections.ArrayList
$fightlist.add("https://youtu.be/eBShN8qT4lk?t=45s") #fight for your right to party
$fightlist.add("https://youtu.be/9jK-NcRmVcw?t=14s") #final countdown
$fightlist.add("https://youtu.be/l__NCIoEObQ?t=38s") #fight the power
$fightlistMeasure = $fightlist | measure
$script:fightlistCount = $fightlistMeasure.count
$script:fightcount = 0

#these are slower songs used for when we are walking, exploring, or sleeping.
$script:walklist = New-Object System.Collections.ArrayList
$walklist.add("https://youtu.be/BmPFioq1l6o?t=23s") #500 miles
$walklist.add("https://youtu.be/Lq0fUa0vW_E") #Walk the line
$walklistMeasure = $walklist | measure
$script:walklistCount = $walklistMeasure.count
$script:walkcount = 0

function fight{
    Invoke-Expression $volumeDown

    try{
    $script:fight.quit()
    }
    catch{
    echo "no running fight process"
    }

    $site = $fightlist[0]
    echo "site is $site"
    $script:fight = New-Object -ComObject InternetExplorer.Application
    $script:fight.Navigate("$site")
    #$script:fight.visible = $true

    try{
    Start-Sleep -Seconds 2
    $script:walk.quit()
    }
    catch{
    echo "no running walk process"
    }

    Start-Sleep -Seconds 2
    Invoke-Expression $volumeUp
    $script:fightlist.Remove($site)
    echo "current fightlist is $script:fightlist"
    $script:fightcount ++
}

function walk{
    Invoke-Expression $volumeDown

    try{
        $script:walk.quit()
    } catch{
        echo "no process"
    }

    $site = $walklist[0]
    echo "site is $site"
    $script:walk = New-Object -ComObject InternetExplorer.Application
    $script:walk.Navigate("$site")
    #$script:walk.visible = $true

    try{
        start-sleep -Seconds 2
        $script:fight.quit()
    } catch{
        echo "no process"
    }

    Start-Sleep -Seconds 2
    Invoke-Expression $volumeUp
    $script:walklist.Remove($site)
    echo "current walklist is $script:walklist"
    $script:walkcount++
}

$input = ""
while ($input -ne "quit"){
$input = Read-Host "`n`nWhich scene? (walk, fight, or stop)"

    if($input -eq "fight"){
        if($script:fightcount -lt $script:fightlistCount){
    fight
    }
    else{
    echo "out of fight song choices!"
    }
    }

    if($input -eq "walk"){
        if ($script:walkcount -lt $script:walklistCount){
    walk
    }
    else{
    echo "out of walk song choices!"
    }
    }
    
    if($input -eq "stop"){
    try{
    $ieProcess = get-process -name "iexplore"
    Stop-Process $ieProcess
    }
    catch{
    echo "no IE open"
    }
    exit
    }
  }












