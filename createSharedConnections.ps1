# this script iterates through a list of projects read in from a file and shares a service connection with each project
# before the service conn can be created, the old one must be removed first

# read in orgs from a file
$projects = Get-Content -Path "./orgs.txt" | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '^#' }

# Login to Azure DevOps
echo $env:ADO_PAT | az devops login --org $ado_org

    # iterate all orgs 
foreach ($ado_project in $projects) {
    # print out org name
    Write-Host "Project: $project"

    $ado_connectionId = "a56f4b70-a810-4e31-8c6c-6f083c92977b"
    $ado_org = 'https://dev.azure.com/rschwarz0884/'


    # Get the project ID
    $project = az devops project show --org $ado_org --project $ado_project | ConvertFrom-Json
    $projectId = $project.id
    $projectName = $project.name

    # Get existing service connections
    $existingConnections = Invoke-RestMethod -Uri ("{0}{1}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4" -f $ado_org, $projectId) -Headers @{'Authorization' = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:ADO_PAT)"))}

    # Check if a service connection with the same name or ID already exists
    $existingConnection = $existingConnections.value | Where-Object { $_.name -eq $projectName -or $_.id -eq $ado_connectionId }

    if ($existingConnection) {
        # Delete the existing service connection
        Invoke-RestMethod -Uri ("{0}/{1}/_apis/serviceendpoint/endpoints/{2}?api-version=6.1-preview.4" -f $ado_org, $projectId, $existingConnection.id) -Headers @{'Authorization' = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:ADO_PAT)"))} -Method Delete
    }
    
    # Use the json template we created as the body of the API call
    $body = Get-Content -path "./sharedconnection.json" -Raw

    # Inject the project id and project name of the service connection to share into the body
    $body = $body.Replace("_id_", $projectId)
    $body = $body.Replace("_name_", $projectName)

    # Call the Azure DevOps Rest API to share the service connection
    $params = @{'Uri' = 
        ('{0}/_apis/serviceendpoint/endpoints/{1}?api-version=6.0-preview.4' -f $ado_org, $ado_connectionId)
        'Headers'     = @{'Authorization' = 'Basic ' +  
                        [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:ADO_PAT)"))}
        'Method'      = 'PATCH'
        'ContentType' = 'application/json'
        'Body'        = ($body)}
    # Invoke-RestMethod @params

} # end of foreach
