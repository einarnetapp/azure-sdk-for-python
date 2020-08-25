param (
  # url list to verify links. Can either be a http address or a local file request. Local file paths support md and html files.
  [string] $sourceDir,
  # file that contains a set of links to ignore when verifying
  [string] $ignoreLinksFile = "$PSScriptRoot/ignore-links.txt",
  # switch that will enable devops specific logging for warnings
  [switch] $devOpsLogging = $false,
  [string] $branchReplaceRegex = "^(https://github.com/.*/(?:blob|tree)/)master(/.*)$",
  # the substitute branch name or SHA commit
  [string] $releaseTag = ""
)

Write-Host "Source directory $sourceDir"
Write-Host "ReleaseSha $releaseTag"

if ($sourceDir) {
  Write-Host "1. $sourceDir"
  $files = Get-ChildItem -Path $sourceDir
  foreach ($file in $files) {
    Write-Host "This is the item name. $file"
  }
  $urls = Get-ChildItem -Path $sourceDir -Recurse -Include *.md
  if ($urls.Count -eq 0) {
    Write-Host "Usage $($MyInvocation.MyCommand.Name) <urls>";
    exit 1;
  }  
}

foreach ($url in $urls) {

  Write-Host "2. Let's start $url"
  $regex = new-object System.Text.RegularExpressions.Regex ($branchReplaceRegex,
      [System.Text.RegularExpressions.RegexOptions]"Singleline, IgnoreCase")
  $ReplacementPattern = "`${1}$releaseTag`$2"
  (Get-Content -Path $url) -replace $regex, $ReplacementPattern | Set-Content -Path $url
  $line = Get-Item -Path $url | Get-Content -Tail 1
  Write-Host "3. $line"
}
