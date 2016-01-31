# The path/directory we're running in.
$path = Split-Path -Parent $MyInvocation.MyCommand.Path
$name = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# The configuration settings.
$config = ([xml](Get-Content ("{0}\{1}.xml" -f $path, $name))).Settings

function Get-RRTPRate()
{
    ConvertFrom-Json (Invoke-WebRequest $config.RRTPUrl).Content
}

function Get-LastThresholdName
{
    try
    {
        $value = (Get-Content -Path "$($config.LastThresholdFileName)" -ErrorAction SilentlyContinue)

        if (-not $value)
        {
            "N/A"
        }
        else
        {
            $value
        }
    }
    catch
    {
        "N/A"
    }
}

function Set-LastThresholdName ([string] $ThresholdName)
{
    Out-File -FilePath "$($config.LastThresholdFileName)" -InputObject "$ThresholdName"
}

function Get-RateThreshold (
    [double] $Rate)
{
    $done = $false

    $config.Thresholds.ChildNodes |
        ? {
            -not $done
        } |
        % {
            if ($Rate -le $_.Value) 
            {

                $_ 

                $done = $true
            }
        }
}

function Invoke-ReportThreshold ($Threshold, [double] $Rate)
{
    $body = ConvertTo-Json -InputObject @{ value1 = $Threshold.Name; value2 = $Rate; value3 = $Threshold.Color }

    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.add('content-type','application/json')
    $webClient.UploadString(($config.Maker.Url -f $config.Maker.EventName, $config.Maker.Key), "POST", "$body") > $null
}

function Invoke-RRTPCheck
{
    $price = (Get-RRTPRate)[0].price

    $lastThresholdName = Get-LastThresholdName
    $currentThreshold = Get-RateThreshold $price

    if ($lastThresholdName -ne $currentThreshold.Name) 
    {
        Invoke-ReportThreshold $currentThreshold $price

        <#
        "Last threshold was: $lastThresholdName"
        "Current threshold is: $($currentThreshold.Name)"
        #>
    }

    Set-LastThresholdName $currentThreshold.Name
}

Invoke-RRTPCheck
