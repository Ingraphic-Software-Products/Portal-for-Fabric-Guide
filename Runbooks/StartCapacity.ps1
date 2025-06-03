# START FABRIC CAPACITY POWERSHELL 7.2 RUNBOOK
try
{
    "Runbookupdate: Sign-in Service Principal towards Azure..."
    $pscredential = Get-AutomationPSCredential -Name 'DeploymentServicePrincipal'
    $tenantId = Get-AutomationVariable -Name 'TenantID'
    $subscriptionID = Get-AutomationVariable -Name 'SubscriptionID'
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
    Set-AzContext -Subscription $subscriptionID -Tenant $tenantId
    "Runbookupdate: Sign-in to Azure Completed"

    # Get variables
    $FabricCapacityName = Get-AutomationVariable -Name 'FabricCapacityName'
    $resourceGroup = Get-AutomationVariable -Name 'ResourceGroupName'

    # Get day of week as e.g. 3 and store in variable dayOfWeek (1 = Monday)
    $dayOfWeek = [Int] (Get-Date).DayOfWeek

    # Get month number as e.g. 5 and store in variable monthNumber
    $monthNumber = [int] (Get-Date).Month
    "Runbookupdate: Finished setting variables"

    $embeddingCapacity = Get-AzFabricCapacity -CapacityName $FabricCapacityName -ResourceGroupName $resourceGroup

    "Runbookupdate: Got AzFabricCapacity"

    $state = $embeddingCapacity.State

    "Runbookupdate: Got AzFabricCapacity state: " + $state

        
    If($state -eq "Paused" -and $dayOfWeek -lt 6 -and $dayOfWeek -ne 0 # Not in weekend.
    ){
        "Runbookupdate: License is paused and it is business time. Starting license."
        Resume-AzFabricCapacity -CapacityName $FabricCapacityName -PassThru -ResourceGroupName $resourceGroup
        "Runbookupdate: License start method completed successfully"

    }Else{
        "Runbookupdate: Status: Active or it is not a business day. No action taken"
        "Runbookupdate: State: " + $state
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
