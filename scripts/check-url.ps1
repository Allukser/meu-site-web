param([string]$Url = "https://roangela-psicologa.com.br/")
try {
  $resp = Invoke-WebRequest -Uri $Url -Method Head -MaximumRedirection 5 -TimeoutSec 25 -UseBasicParsing
  Write-Host "STATUS=$($resp.StatusCode)"
  Write-Host "FINAL_URL=$($resp.BaseResponse.ResponseUri.AbsoluteUri)"
  $resp.Headers.GetEnumerator() | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }
} catch {
  Write-Host "ERROR=$($_.Exception.Message)"
  if ($_.Exception.Response) {
    Write-Host "STATUS=$([int]$_.Exception.Response.StatusCode)"
  }
}
