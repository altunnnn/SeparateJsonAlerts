param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = ""
)

function Format-JsonLogs {
    param(
        [string]$InputPath,
        [string]$OutputPath
    )
    
    try {
        $content = Get-Content -Path $InputPath -Raw
        
        $formattedContent = $content -replace '},\{"ts"', "},`n`n{`"ts`""
        
        $formattedContent = $formattedContent -replace '},\{"_path"', "},`n`n{`"_path`""
        
        if ($OutputPath -ne "") {
            $formattedContent | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Formatted logs saved to: $OutputPath" -ForegroundColor Green
        } else {
            $directory = Split-Path -Parent $InputPath
            $filename = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
            $extension = [System.IO.Path]::GetExtension($InputPath)
            $defaultOutput = Join-Path $directory "$filename`_formatted$extension"
            
            $formattedContent | Out-File -FilePath $defaultOutput -Encoding UTF8
            Write-Host "Formatted logs saved to: $defaultOutput" -ForegroundColor Green
        }
        
        $originalLines = ($content -split '},\{"').Count
        Write-Host "Processing complete!" -ForegroundColor Cyan
        Write-Host "Number of log entries found: $originalLines" -ForegroundColor Yellow
        
    } catch {
        Write-Error "Error processing file: $_"
    }
}

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file '$InputFile' not found!"
    exit 1
}

Format-JsonLogs -InputPath $InputFile -OutputPath $OutputFile

Write-Host "`nPreview of formatted output:" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

if ($OutputFile -eq "") {
    $directory = Split-Path -Parent $InputFile
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $extension = [System.IO.Path]::GetExtension($InputFile)
    $previewFile = Join-Path $directory "$filename`_formatted$extension"
} else {
    $previewFile = $OutputFile
}

Get-Content $previewFile | Select-Object -First 20 | ForEach-Object { Write-Host $_ }