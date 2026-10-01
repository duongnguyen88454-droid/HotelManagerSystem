$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginUrl = "http://localhost:8080/HotelManagerSystem/login"

try {
    $loginPage = Invoke-WebRequest -Uri $loginUrl -WebSession $session -TimeoutSec 5
    Write-Output "Login page reachable: $($loginPage.StatusCode)"

    # Login as receptionist
    $loginBody = @{
        email = "huong.nv@hotel.com"
        password = "1234"
    }
    $loginResponse = Invoke-WebRequest -Uri $loginUrl -Method POST -Body $loginBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue

    Write-Output "Login Status: $($loginResponse.StatusCode)"
    Write-Output "Redirect Location: $($loginResponse.Headers.Location)"

    # Access room-map
    $roomMapUrl = "http://localhost:8080/HotelManagerSystem/receptionist/room-map"
    $roomMapResponse = Invoke-WebRequest -Uri $roomMapUrl -WebSession $session
    Write-Output "Room-map Status: $($roomMapResponse.StatusCode)"

    $html = $roomMapResponse.Content
    # Check KPI and rooms
    if ($html -match "Tổng số phòng:\s*<strong>(\d+)</strong>") {
        Write-Output "Total rooms KPI: $($Matches[1])"
    } else {
        Write-Output "Total rooms KPI regex did not match"
    }

    if ($html -match "\[Đã dọn\]\s*</span>\s*:\s*<strong>(\d+)</strong>") {
        Write-Output "Available rooms KPI: $($Matches[1])"
    }
    if ($html -match "\[Đang có khách\]\s*</span>\s*:\s*<strong>(\d+)</strong>") {
        Write-Output "Occupied rooms KPI: $($Matches[1])"
    }
    if ($html -match "Tỷ lệ lấp đầy:\s*<strong[^>]*>([^<]+)</strong>") {
        Write-Output "Occupancy rate KPI: $($Matches[1])"
    }

    # Check for room rows
    $roomMatches = [regex]::Matches($html, 'data-room="(P\d+)"')
    Write-Output "Number of rendered room rows: $($roomMatches.Count)"
    foreach ($m in $roomMatches) {
        Write-Output "Found room in HTML: $($m.Groups[1].Value)"
    }
} catch {
    Write-Output "Error: $_"
}
