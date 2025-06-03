# PAUSE FABRIC CAPACITY POWERSHELL 7.2 RUNBOOK
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

    If( $state -eq "Paused" ){
        "Runbookupdate: License state: " + $state  
        "Runbookupdate: Already paused. No action taken"
    }Else{
        "Runbookupdate: License is not paused. Suspending license."
        Suspend-AzFabricCapacity -CapacityName $FabricCapacityName -PassThru -ResourceGroupName $resourceGroup
        "Runbookupdate: License suspend method completed successfully"
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
