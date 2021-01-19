function RunCoverage {
    param(
        [Parameter(Mandatory=$true)]
        [String] $pathProject,
        [Parameter(Mandatory=$true)]
        [String] $coverageOutputPath
    )

    [string] $coverageOutputFile = (Get-Item $pathProject).BaseName.ToLower()
    $coverageOutputFile = "converage.$coverageOutputFile.xml"
    $coverageOutputFile = Join-Path $coverageOutputPath -ChildPath $coverageOutputFile

    if (Test-Path $coverageOutputFile -PathType Leaf)
    {
        Remove-Item $coverageOutputFile
    }

    $result = & dotnet test $pathProject /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput=$coverageOutputFile

    $objResult = New-Object psobject
    Add-Member -InputObject $objResult -MemberType NoteProperty -Name "exittext" -Value $result
    Add-Member -InputObject $objResult -MemberType NoteProperty -Name "exitcode" -Value $LASTEXITCODE

    return $objResult
}

function RunAllTestsCoverage() {
    param(
        [string]$projectName = ""
    )
    $icon = [Char]0x25BA
    [string] $pathRoot = (Get-Item $PSScriptRoot).parent.parent.FullName
    [string] $coverageOutputPath = Join-Path $PSScriptRoot -ChildPath ".coverage\"
    [string] $extensionProject = "*.csproj"

    $projects = Get-ChildItem -Path $pathRoot -Filter $extensionProject -Recurse | Sort-Object -Property Name
    
    $UnitTestProjects = $projects.Where( { ([string]$_.Name).ToLower().EndsWith("unittest.csproj") } )

    Write-Host "Found $($UnitTestProjects.Count) UnitTest projects in `"$pathRoot`"" -ForegroundColor DarkYellow

    ForEach ($pathProject in $UnitTestProjects) {

        if ($projectName -ne "" -and $pathProject.Name -notlike "*$projectName*")
        {
            continue;
        }

        Write-Host $icon $pathProject.Name -ForegroundColor Blue -NoNewline
        
        $result = RunCoverage -pathProject $pathProject.FullName -coverageOutputPath $coverageOutputPath
    
        if ($result.exitcode -ne 0) {
            Write-Host " - FAIL" -ForegroundColor Red
            Write-Host $result.exittext -ForegroundColor Cyan
        } else {
            Write-Host " - SUCCESS" -ForegroundColor Green
        }
    }
}

function GenerateCoverageReport {
    [string] $coveragePath = Join-Path $PSScriptRoot -ChildPath ".coverage"

    [string] $reportsList = Get-ChildItem $coveragePath -Filter *.xml | Join-String -Separator ";"

    dotnet "$env:USERPROFILE\.nuget\packages\reportgenerator\4.3.9\tools\netcoreapp2.1\ReportGenerator.dll" -targetdir:$coveragePath\report -reporttypes:Html -verbosity:Error -reports:$reportsList
}

Write-Host "Coletando metricas de cobertura de codigo" -ForegroundColor Magenta
RunAllTestsCoverage -projectName $args[0]

Write-Host "Gerando relatorio" -ForegroundColor Magenta
GenerateCoverageReport

Write-Host "Relatório gerado com sucesso" -ForegroundColor Magenta
Write-Host (Join-Path $PSScriptRoot -ChildPath ".coverage\report\index.htm")