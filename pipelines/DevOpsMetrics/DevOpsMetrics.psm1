class PipelineMetadata {
    [String]$GitCommit
    [String]$GitBranch
    [String]$GitUrl
    [String]$TfsPipelineName
    [String]$TfsBuildUrl
    [String]$Status    
    [String]$TfsBuildId
}

Function Get-BuildInformation {
    [OutputType([PipelineMetadata])]
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$tfsProjectKey,
        [parameter (Mandatory = $true, position = 1)]
        [String]$tfsBuildId
    )

    $buildUrl = [string]::Format("https://azuredevops.optum.com/tfs/UHG/{0}/_apis/build/builds/{1}", $tfsProjectKey, $tfsBuildId)
    Write-Host "INFO: Fetching build info from $buildUrl"
    $result = Invoke-RestMethod -Uri $buildUrl -Method Get  -UseDefaultCredentials -ContentType "application/json"

    $repoId = $result.repository.id

    return [PipelineMetadata]@{
        GitCommit       = $result.sourceVersion
        GitBranch       = $result.sourceBranch
        GitUrl          = "https://github.optum.com/$repoId.git"
        TfsPipelineName = $result.definition.name
        TfsBuildUrl     = $result.url
        Status          = "Completed"        
        TfsBuildId      = $tfsBuildId
    }
}

class OptumMetadata {
    [String[]]$AskIds
    [String]$MileStoneId
    [String]$CaAgileId
    [String]$ProjectKey
}

Function Get-OptumMetada {
    [OutputType([OptumMetadata])]
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$filePath
    ) 

    return [OptumMetadata](Get-Content -Path $filePath | ConvertFrom-Json)
}

Function Send-DevOpsMetrics {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$AskId,
        [parameter (Mandatory = $true, position = 1)]
        [String]$MileStoneId,
        [parameter (Mandatory = $true, position = 2)]
        [String]$CaAgileId,
        [parameter (Mandatory = $true, position = 3)]
        [String]$ProjectKey,
        [parameter (Mandatory = $true, position = 4)]
        [PipelineMetadata]$PipelineMetadata
    ) 

    $body = [ordered]@{
        eventData    = @{
            type         = "pipeline.build" 
            status       = $PipelineMetadata.Status
            # This Time is not super accurate, as it is the time this event was created, not when it actually happened
            timestamp_ms = [int64] (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date).ToUniversalTime()).TotalMilliseconds
        } 
        pipelineData = @{
            projectKey  = $ProjectKey
            gitCommit   = $PipelineMetadata.GitCommit
            gitBranch   = $PipelineMetadata.GitBranch
            askId       = @(
                $AskId
            ) 
            milestoneId = $MileStoneId
            caAgileId   = $CaAgileId 
            pipelineId  = $PipelineMetadata.TfsPipelineName
            gitURL      = $PipelineMetadata.GitUrl
            isTestMode  = $false
        } 
        buildData    = @{
            buildUrl = $PipelineMetadata.TfsBuildUrl
            buildId  = $PipelineMetadata.TfsBuildId
        }
    }

    $jsonBody = $body | ConvertTo-Json -Depth 10

    $devopsUrl = "http://kafkaposter-pipeline-events.optum.com/postevent"
    return  Invoke-RestMethod -Uri $devopsUrl   -Method Post -ContentType "application/json" -Body $jsonBody
}

Function Send-SpecificMetric {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$AskId,
        [parameter (Mandatory = $true, position = 1)]
        [String]$MileStoneId,
        [parameter (Mandatory = $true, position = 2)]
        [String]$CaAgileId,
        [parameter (Mandatory = $true, position = 3)]
        [String]$ProjectKey,
        [parameter (Mandatory = $true, position = 4)]
        [PipelineMetadata]$PipelineMetadata,
        [parameter (Mandatory = $true, position = 5)]
        $PropertiesToAppend
    ) 

    $body = [ordered]@{
        pipelineData = @{
            projectKey  = $ProjectKey
            gitCommit   = $PipelineMetadata.GitCommit
            gitBranch   = $PipelineMetadata.GitBranch
            askId       = @(
                $AskId
            ) 
            milestoneId = $MileStoneId
            caAgileId   = $CaAgileId 
            pipelineId  = $PipelineMetadata.TfsPipelineName
            gitURL      = $PipelineMetadata.GitUrl
            isTestMode  = $false
        }        
    }

    $fullBody = $body + $PropertiesToAppend

    $jsonBody = $fullBody | ConvertTo-Json -Depth 10

    $devopsUrl = "http://kafkaposter-pipeline-events.optum.com/postevent"    
    
    return  Invoke-RestMethod -Uri $devopsUrl   -Method Post -ContentType "application/json" -Body $jsonBody
}

Function Get-MatchOrEmpty {
    param (
        [Parameter()]
        [String]
        $Contents,
        [Parameter()]
        [String]
        $Pattern
    )

    $value = "";    
    $matchExists = ($Contents -match $Pattern )    
    if ($matchExists) {
        $possibleMatches = $Contents | Select-String -Pattern $Pattern
    
        $value = $possibleMatches.Matches.Groups[1].Value.Trim();
    }

    return $value
}

Function Get-TaskMetadata {    
    param (
        [Parameter()]
        [String]
        $TaskLogContents
    )
    
    $friendlyName = Get-MatchOrEmpty $TaskLogContents '##\[section\]Starting\s*:(.*)';
    $officialName = Get-MatchOrEmpty $TaskLogContents 'Task\s*:(.*)';
    $author = Get-MatchOrEmpty $TaskLogContents 'Author\s*:(.*)';
    
    return [PSCustomObject]@{
        FriendlyName = $friendlyName
        OfficialName = $officialName
        Author       = $author
    }
}

Function Get-EpochMS {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$lastChangedOn
    )
    return (New-TimeSpan -Start (Get-Date "01/01/1970") -End ($lastChangedOn)).TotalMilliseconds
}

Function Get-BuildLogLinks {    
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$tfsProjectKey,
        [parameter (Mandatory = $true, position = 1)]
        [String]$tfsBuildId
    )

    $buildUrl = [string]::Format("https://azuredevops.optum.com/tfs/UHG/{0}/_apis/build/builds/{1}/logs", $tfsProjectKey, $tfsBuildId)
    Write-Host "INFO: Fetching build log info from $buildUrl"
    $result = Invoke-RestMethod -Uri $buildUrl -Method Get  -UseDefaultCredentials -ContentType "application/json"           

    return $result.value | % { @{
            Url          = $_.url
            timestamp_ms = Get-EpochMS $_.lastChangedOn
        } }
}

Function Get-BuildLog {
    [OutputType([PipelineMetadata])]
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$BuildLogUrl,
        [parameter (Mandatory = $true, position = 1)]
        [long]$timestamp_ms
    )
    
    Write-Host "INFO: Fetching build log info from $BuildLogUrl"
    $result = Invoke-RestMethod -Uri $BuildLogUrl -Method Get  -UseDefaultCredentials          

    $taskMetadata = Get-TaskMetadata $result

    return [PSCustomObject]@{
        Contents     = $result
        Metadata     = $taskMetadata
        timestamp_ms = $timestamp_ms
    };
}

Function Send-BuildEvent {
    $tfsBuildId = $env:BUILD_BUILDID
    $tfsProjectKey = $env:SYSTEM_TEAMPROJECTID
    $pipelineMetada = Get-BuildInformation $tfsProjectKey $tfsBuildId
    $optumMetada = Get-OptumMetada "./devopsmetrics.json" # From point where Agent is being ran, typically repo root
    
    $askIds = $optumMetada.AskIds
    $mileStoneId = $optumMetada.MileStoneId
    $caAgileId = $optumMetada.CaAgileId
    $projectKey = $optumMetada.ProjectKey
    
    FOREACH ($askId in $askIds) {
        Send-DevOpsMetrics $askId $mileStoneId $caAgileId $projectKey $pipelineMetada | Write-Host
    }
}

Function IsOfficialSonarScan {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [PSCustomObject]$LogMetadata                
    )

    if ($LogMetadata.OfficialName -eq "Run Code Analysis" -and $LogMetadata.Author -eq "sonarsource") {
        return $true
    }

    return $false
}

Function Get-OfficialSonarScanEvent {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$contents,
        [parameter (Mandatory = $true, position = 1)]
        [long]$timestamp_ms
    )

    $scanUrl = Get-MatchOrEmpty $contents 'INFO: ANALYSIS SUCCESSFUL, you can browse(.*)';

    return [ordered]@{
        eventData       = @{
            status       = "Complete"
            timestamp_ms = $timestamp_ms
            type         = "pipeline.quality_scan.sonar"
        }
        qualityScanData	= @{
            resultsURL = $scanUrl
        }
        sonarData       = @{
            isPreview         = $false
            loc               = 0
            sonarMetrics      = "na"
            scanTool          = "Azure DevOps"
            sonarQualityGate  = "NA"
            targetQualityGate = "NA"
            unitTestMetrics   = "NA"
        }
    }
}

Function IsOfficialFortifyScan {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [PSCustomObject]$LogMetadata                
    )

    if ($LogMetadata.OfficialName -eq "Fortify Static Code Analyzer Assessment" -and $LogMetadata.Author -eq "Micro Focus") {
        return $true
    }

    return $false
}

Function Get-OfficialFortifyScanEvent {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$contents,
        [parameter (Mandatory = $true, position = 1)]
        [long]$timestamp_ms
    )

    $buildId = Get-MatchOrEmpty $contents '-b\s(\S+)\s';
    $application = Get-MatchOrEmpty $contents '-application\s(\S+)\s';
    $version = Get-MatchOrEmpty $contents '-applicationVersion\s(\S+)\s';
    $baseUrl = Get-MatchOrEmpty $contents '-url\s(\S+)\s';

    $scanUrl = "$baseUrl/";

    return [ordered]@{
        eventData       = @{
            status       = "Complete"
            timestamp_ms = $timestamp_ms
            type         = "pipeline.quality_scan.fortify"
        }
        qualityScanData	= @{
            resultsURL = $scanUrl
        }
        fortifyData     = @{
            fortifyBuildName    = $buildId
            fortifyIssues       = "NA"
            scanType            = "full"
            scarProjectName     = $application
            scarProjectVersion  = $version
            translateExclusions = "NA"            
        }
    }
}

Function Get-DevOpsEvents {    
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$tfsProjectKey,
        [parameter (Mandatory = $true, position = 1)]
        [String]$tfsBuildId
    )

    $logsWithMetadata = Get-BuildLogLinks $tfsProjectKey $tfsBuildId | % { Get-BuildLog $_.Url $_.timestamp_ms }

    $events = foreach ($log in $logsWithMetadata) {       
        if ((IsOfficialSonarScan $log.Metadata)) {            
            Get-OfficialSonarScanEvent $log.Contents $log.timestamp_ms;            
        }

        if ((IsOfficialFortifyScan $log.Metadata)) {            
            Get-OfficialFortifyScanEvent $log.Contents $log.timestamp_ms;            
        }
    }

    return $events
}

Function Send-DevOpsEvents {
    param (
        [parameter (Mandatory = $true, position = 0)]
        [String]$tfsProjectKey,
        [parameter (Mandatory = $true, position = 1)]
        [String]$tfsBuildId
    )

    $pipelineMetada = Get-BuildInformation $tfsProjectKey $tfsBuildId
    $optumMetada = Get-OptumMetada "./devopsmetrics.json" # From point where Agent is being ran, typically repo root
    
    $askIds = $optumMetada.AskIds
    $mileStoneId = $optumMetada.MileStoneId
    $caAgileId = $optumMetada.CaAgileId
    $projectKey = $optumMetada.ProjectKey

    $devOpsEvents = Get-DevOpsEvents $tfsProjectKey $tfsBuildId
    
    FOREACH ($askId in $askIds) {
        FOREACH ($event in $devOpsEvents) {            
            Send-SpecificMetric $askId $mileStoneId $caAgileId $projectKey $pipelineMetada $event | Write-Host
        }
    }

    return $events
}

Function AutoSend-DevOpsEvents {
    $tfsProjectKey = $env:SYSTEM_TEAMPROJECTID
    $tfsBuildId = $env:BUILD_BUILDID

    return Send-DevOpsEvents $tfsProjectKey  $tfsBuildId
}