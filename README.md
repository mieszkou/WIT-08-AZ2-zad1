## Zadanie:

```
Napisz skrypt, który wykona następujące czynności:

sprawdzi liczbę dostępnych regionów - policzy je i zwróci wynik w postaci liczby
przygotuje grupę zasobów, których nazwa będzie złożona w następujący sposób - RG-<nazwa projektu>-<nazwa regionu>
tworzymy tyle grup ile jest dostępnych regionów i które w nazwie mają człon euro
przygotuj raport w postaci tabeli o atrybutach: nazwa grupy, region - wynik wyświetl na ekranie
napisz funkcję, która skasuje wszystkie założone obiekty w subskrypcji
Wynik skryptu ma wyglądać podobnie do tego:
Liczba regionów: X
-----Tworze grupy
Raport grup:
Tabela z wynikiem: Nazwa grupy, 
-----Kasuje Obiekty
-----Koniec skryptu

Jako wynik zadania wklej: skrypt + screen z wynikiem
```

## Notatki

```
Prowadzący: inż. Marcin Bodzan 
Zapoznanie z przedmiotem. 
Zasady zaliczenia. 

Install-Module -Name AZ -AllowClobber -Scope AllUsers 

#nawiązywanie połączenia do Azure  

Connect-AzAccount  

get-command -Module AZ.Resources  

#listowanie zasobów w Azure  
Get-AzResource  
Get-AzResource |measure  

Get-AzResourceGroup -Name RG_ASC_B  
  

#lista lokalizacji  

Get-AzLocation  

#tworzenie nowej RG  

New-AzResourceGroup -Name "RG_ASC_AB" -Location 'northeurope'  

   

#kasowanie RG  

#$res = Get-AzResource -Name dysk-sql  

$res = Get-AzResourceGroup -Name RG_ASC_AB  

Remove-AzResource -ResourceId $res.ResourceId -Force  

   

#tworzenie viertualnej sieci  

New-AzVirtualNetwork -ResourceGroupName "RG_ASC_B" -Location "northeurope" -Name WITNET -AddressPrefix 10.10.0.0/16  

  

New-AzResourceGroup -Name "RG_ASC_A" -Location 'northeurope'  

  

#przesuwanie zasobów pomiędzy grupami  

   

Get-AzResource | where {$_.ResourceGroupName -EQ "RG_ASC_B"} | Move-AzResource -ResourceId {$_.ResourceId} -DestinationResourceGroupName RG_ASC_A -force  

  

   

  

   

#Zapisanie hasła jako bezpieczny ciąg znaków  

$vmcred = Read-Host -AsSecureString  

   

   

#Tworzenie zmiennej z poświadczeniami   

$vmcred2 = Get-Credential -Message "podaj login dla VM"  

   

#Tworzymy VM w Azure  

   

#tworzenie nowej RG  

New-AzResourceGroup -Name "RG_ASC_ABC" -Location 'northeurope'  

   

   

#tworzenie viertualnej sieci  

$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName "RG_ASC_ABC" -Location "northeurope" -Name WITNET -AddressPrefix 10.10.0.0/16  

   

#Get-AzVirtualNetwork  

   

$subnetConfig =Add-AzVirtualNetworkSubnetConfig -Name WITSubnet -AddressPrefix "10.10.10.0/24" -VirtualNetwork $virtualNetwork  

   

#kojarzenie sieci i podsieci  

$virtualNetwork  | Set-AzVirtualNetwork  

   

   

#tworznie maszyny wirtualnej z PowerShell  

New-AzVm -ResourceGroupName RG_ASC_ABC -Location "northeurope" -Name "wit-VM1" -VirtualNetworkName WITNET -SubnetName WITSubnet -OpenPorts 80,3389 -Image "Win2016Datacenter" -Credential $vmcred2  

   

#end tworzenie VM  

   

  

   

New-AzVm `  

-ResourceGroupName "RG_ASC_ABC" `  

-Name "myVAZ" `  

-Location "northeurope" `  

-VirtualNetworkName "WITNET" `  

-SubnetName "WITSubnet" `  

-SecurityGroupName "myNetworkSecurityGroup" `  

-PublicIpAddressName "myPublicIpAddress" `  

-Credential $vmcred2 `  

-OpenPorts 80,3389  

   

  

  

https://learn.microsoft.com/en-us/powershell/module/az.accounts/set-azcontext?view=azps-9.1.0  

  

  

  

  

   

#Wylistowanie nazw interfejsów oraz publicznych adresów IP  

   

Get-AzPublicIpAddress -ResourceGroupName RG_ASC_ABC | Select Name, IpAddress  

  

   

#tworzenie reguł do Network Security Group (NSG)  

$rola1 = New-AzNetworkSecurityRuleConfig -Name RDP-allow -Description "Allow RDP from internet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389  

$rola2 = New-AzNetworkSecurityRuleConfig -Name HTTP-allow -Description "Allow HTTP from internet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80  

   

#tworzenie NSG   

$NSG1 = New-AzNetworkSecurityGroup -ResourceGroupName "RG_ASC_ABC" -Location "northeurope" -Name "NSG-FrontEnd-lab" -SecurityRules $rola1,$rola2  

   

   

#informacja o istniejącym NSG  

$nsg = Get-AzNetworkSecurityGroup -Name NSG-FrontEnd-lab -ResourceGroupName RG_ASC_ABC  

   

#dodajemy nowe reguły  

   

$nsg | Add-AzNetworkSecurityRuleConfig -Name RDP-allow -Description "Allow RDP from internet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -DestinationAddressPrefix * -SourcePortRange * -DestinationPortRange 3389  

   

#update  

$nsg | Set-AzNetworkSecurityGroup  

   

  

   

#wywołanie skryptu na maszynie virtualnej  

Invoke-AzVMRunCommand -ResourceGroupName RG_ASC_ABC -VMName myVAZ -CommandId 'RunPowerShellScript' -ScriptPath "C:\skrypty\sample.ps1"  

   

# dodatkowa informacja dla Invoke-AzVMRunCommand  

#The cmdlet expects the script referenced in the -ScriptPath parameter to be local to where the cmdlet is being run. If you are running it from your local machine, the script will need to be stored on #your machine. If you are running the script from Cloud Shell, you will need to have the script available in your Cloud Shell.   

  

   

#Wylistowanie nazw interfejsów oraz publicznych adresów IP  

Get-AzPublicIpAddress -ResourceGroupName RG_ASC_ABC | Select Name, IpAddress  

   

   

#uruchomienie przeglądraki internetowej z wskazanym adresem  

Start-Process http://13.80.128.210  

   

   

#zmiana subskrypcji do działania  

Get-AzSubscription  

   

$context = Get-AzSubscription -SubscriptionId ...  

Set-AzContext $context   

  

  

  

Tworzenie strony www z PowerShell  

# The following code will create an IIS site and it associated Application Pool.   

# Please note that you will be required to run PS with elevated permissions.   

# Visit http://ifrahimblog.wordpress.com/2014/02/26/run-powershell-elevated-permissions-import-iis-module/  

# set-executionpolicy unrestricted  

Import-Module ServerManager  

Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools  

Add-WindowsFeature Web-Scripting-Tools  

Import-Module WebAdministration  

$SiteFolderPath = "C:\WebSite"              # Website Folder  

$SiteAppPool = "CSBGAppPool"                  # Application Pool Name  

$SiteName = "CSBG"                        # IIS Site Name  

#$SiteHostName = "www.CBSG.PL"            # Host Header  

New-Item $SiteFolderPath -type Directory  

Set-Content $SiteFolderPath\Default.htm "<h1>Hello CBSG Polska Sp. z o.o.</h1>"  

New-Item IIS:\AppPools\$SiteAppPool  

New-Item IIS:\Sites\$SiteName -physicalPath $SiteFolderPath -bindings  

@{protocol="http";bindingInformation=":9090:"+$SiteHostName}  

Set-ItemProperty IIS:\Sites\$SiteName -name applicationPool -value $SiteAppPool  

# Complete   

  

  

#Uśpienie wykonywania skryptu na 5 sekund  

sleep 5  

   

#wyswietlanie zadań (job)  

Get-Job  

Wait-Job -Name  

Wait-Job -InstanceId  

  

#tworzenie maszyny vm z szablonu  

$templateUri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simplewindows/azuredeploy.json"  

New-AzResourceGroupDeployment -Name testrgtempdeployment1 -ResourceGroupName witrg -TemplateUri $templateUri   

  

  

#zmiana NSG dla maszyny wirtualnej  

   

Get-AzNetworkSecurityGroup | Select Name,ResourceGroupName,Location  

   

$NEWnsg = Get-AzNetworkSecurityGroup -ResourceGroupName ‘RG_ASC_ABC’ -Name ‘NSG-FrontEnd’  

   

$net = get-azvm -Name wit-VM1 | select Name, ResourceGroupName, Location -ExpandProperty NetworkProfile  

   

$vNIC = Get-AzNetworkInterface -ResourceGroupName RG_ASC_ABC -Name wit-VM1  

   

$vNIC.NetworkSecurityGroup = $NEWnsg  

   

$vNIC | Set-AzNetworkInterface  

  

 
