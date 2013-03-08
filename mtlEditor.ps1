#############################################
# Script for changing values in mtl files   #
# made by NisseDILLIGAF (nisse@dilligaf.nu) #
#############################################
# Have .mtl file, or folder with .mtl files #
# as argument to this file                  #
#############################################

$materials = @{
    "Bricks" = "mat_concrete"
    "Copper" = "mat_metal"
    "Grass" = "mat_soil"
    "Ground" = "mat_soil"
    "Metal" = "mat_metal"
    "Stone" = "mat_concrete"
    "Beam" = "mat_wood"
    "Window" = "mat_glass_unbreakable"
    "Shutters" = "mat_wood"
    "Door" = "mat_wood"
    "BrickBend" = "mat_concrete"
    "Wood" = "mat_wood"
    "Roof" = "mat_concrete"
    "Puts" = "mat_concrete"
    "Mud" = "mat_soil"
}

# Folders and files NOT to change!
$exclude = @(
    "\\characters\\",
    "\\decals\\",
    "\\default\\",
    "\\editor\\",
    "\\effects\\",
    "\\hardscape\\",
    "\\hud\\",
    "\\library\\",
    "\\Lights\\",
    "\\measurement\\",
    "\\natural\\",
    "\\placeholders\\",
    "\\props\\",
    "\\structures\\",
    "\\weapons\\",
    "\\vehicles\\",
    "helper.mtl",
    "nodraw.mtl"
    )






























if (Test-Path $args -pathtype container) # If it's a folder
{
    Write-Host "Wait for it..."

    $regex = $exclude -join '|'
    $mtlfiles = $(get-childitem $args -recurse -filter "*.mtl"  | where {$_.fullname -notmatch $regex})
    $i = 0
    $y = 0
    
    foreach ($childx in $mtlfiles)
    {
        $y++
        $child = $childx.fullname
        if($child)
        {
            $script:startTime = get-date
            if (./mtlEditor.ps1 $child){$($runtime = $(get-date) - $script:StartTime) ; $i++ ; $edited += "$($runtime.Milliseconds)ms - $child$([Environment]::NewLine)" ; $changed = $childx }
            Write-Progress -activity "Processing $y of $($mtlfiles.count) - Edited $i : $changed" -status "Percent done: " -percentComplete (($y / $mtlfiles.length)  * 100)
        }
    }

    if ($i){ $edited | out-file $args-$i-edited-$(get-date -f yyyyMMdd-HHmm).txt }


    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host

    Write-Host "Press any key to continue ..."

    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else # If it's a file
{

    $dataOrg = Get-Content $args
    $data = Get-Content $args

    $Surface=@()
    $Names=@()
    $mtl=@()


    $data = $data -replace "File=""(.*)/CryTextures", "File=""Textures"

    $data = $data -replace "Diffuse=""(.*?)"" ", "Diffuse=""0.21576439,0.21576439,0.21576439"" "


    # Get material properties and names
    #$prevline = ""
    $prevname = ""

    foreach ($line in $data)
    {
        # Get name of current <Material>
        if ($line -Match "Material Name=""(.*?)""")
        {
            $prevname = $matches[1]
        }
        
        # What name should this <Material> get?
        if ($line -Match "Diffuse.*Textures.*/(.*).dds")
        {
            if ($prevname -eq ""){ $Names += $matches[1] }else{ $Names += $prevname ; $Surface += "" }
        }
        elseif ($line -Match "Diffuse.*Textures.*/(.*[0-9?])") #Något fel här!!!!!   grey.dds" Filter="7"
        {
            $Names += $matches[1]
        }
        elseif ($line -Match "Diffuse.*Textures.*/(.*).tif")
        {
            if ($prevname -eq ""){ $Names += $matches[1] }else{ $Names += $prevname ; $Surface += "" }
        }
        elseif ($line -Match "<Textures />")
        {
            $Names += $prevname
            $Surface += ""
        }
        elseif ($line -Match "<Texture Map=""Diffuse"){ $Names += $prevname }


        # Get SurfaceType for current <Material>
        if ($line -Match 'Textures.*_(.*[^0-9])_')
        {
            if ($materials.ContainsKey($($matches[1])))
            {
                $Surface += $materials.Get_Item($($matches[1]))
            }
            else
            {
                $Surface += ""
            }
        }

        #$prevline = $line
    }


    $i=0
    foreach ($line in $data)
    {
        if ($line -Match 'Material Name')
        {
            $line = $line -replace "Material Name=""(.*?)""", "Material Name=""$($Names[$i])"""
            if ($line -Match "SurfaceType="""""){ $line = $line -replace "SurfaceType=""(.*?)""", "SurfaceType=""$($Surface[$i])""" }
            $i++
        }
        $mtl += $line
    } 

    if ((Compare-Object $dataOrg $mtl))
    {
        Get-Content $args | out-file "$args.bak$(get-date -f yyyyMMdd-HHmm)"
        $mtl | out-file "$args"
        return "1"
    }


}
