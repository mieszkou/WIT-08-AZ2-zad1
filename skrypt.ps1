# Napisz skrypt, który wykona następujące czynności: (...)

$projectName = "WIT08AZ2zad1"

# Install-Module -Name AZ -AllowClobber -Scope AllUsers 

# logowanie interaktywne przy każdym uruchomieniu
$Credentials = Get-Credential

# ... lub automatyczne logowanie na potrzeby testowania
# utworzenie pliku z login/haslo do azure
# $Credentials = Get-Credential
# $Credentials | Export-CliXml "credentials_office_wit.xml"

# oddczytanie zapisanych danych z pliku
# $Credentials = Import-CliXml "credentials_office_wit.xml"

$null = Connect-AzAccount -Credential $Credentials

# ... sprawdzi liczbę dostępnych regionów
$regionsAll  = Get-AzLocation 
$regionsEuro = Get-AzLocation | Where-Object {$_.DisplayName -like "*euro*" -and $_.RegionType -eq "Physical"} 

# ... - policzy je i zwróci wynik w postaci liczby
Write-Host "Liczba regionów (wszystkich): $($regionsAll.Count)"
Write-Host "Liczba regionów (z 'euro' w nazwie): $($regionsEuro.Count)"

# ... przygotuje grupę zasobów, których nazwa będzie złożona 
# ... w następujący sposób - RG-<nazwa projektu>-<nazwa regionu>

Write-Host "-----Tworze grupy"
# lista której użyjemy do wyświetlenia tabeli
$resourceGroups = @()

# ... tworzymy tyle grup ile jest dostępnych regionów 
# ... i które w nazwie mają człon euro

foreach ($region in $regionsEuro) {
    $resourceGroupName = "RG-$projectName-$($region.DisplayName)" -replace '[^-\w\._\(\)]', '-'
    $null = New-AzResourceGroup -Name $resourceGroupName -Location $region.Location
    $resourceGroups += [PSCustomObject]@{
        groupName = $resourceGroupName
        Region = $region.DisplayName
    }
}

# ... przygotuj raport w postaci tabeli o atrybutach: 
# ... nazwa grupy, region - wynik wyświetl na ekranie
Write-Host "Raport grup:"
$resourceGroups | Format-Table

# napisz funkcję, która skasuje wszystkie 
# założone obiekty w subskrypcji
Write-Host "-----Kasuje obiekty"

# funkcja kasująca w oparciu o listę z grupami
function Remove-CreatedRG {
    param ([System.Collections.Generic.List[PSObject]] $resourceGroups)
    foreach ($group in $resourceGroups) {
        # Write-Host "$($group.groupName) -> 🗑️"
        $null = Remove-AzResourceGroup -Name $group.groupName -Force
    }
}
Remove-CreatedRG -resourceGroups $resourceGroups

# lub funkcja kasująca w oparciu o nazwę projektu
function Remove-CreatedRGshort {
    param ([string]$projectName)
    $null = Get-AzResourceGroup -Name "RG-$projectName-*" | Remove-AzResourceGroup -Force
}
# Remove-CreatedRGshort -projectName $projectName

# Koniec skryptu
Write-Host "-----Koniec skryptu"
Write-Host ""
Write-Host "🎹 Naciśnij dowolny klawisz"
Write-Host -Object ('{0}' -f [System.Console]::ReadKey().Key.ToString());
