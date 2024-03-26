Urgent issue affecting migration of thousands of repos
- Migrating from ADO to GitHub.
- Client has 60+ orgs. Per ADO naming convention that cant be circumvented, the service connection has to be named Org-Project.
- When using gh ado2gh rewire-pipeline it requires you to pass in the --service-connection-id, but then instead of using this it does a lookup and expects the service connection to be named the same as the GitHub org (per https://github.com/orgs/github/projects/10606/views/1?pane=issue&itemId=35359441) and https://github.com/github/gh-gei/issues/532 
- Full command: gh ado2gh rewire-pipeline --github-org ORG --ado-org ORG --ado-team-project HI --github-repo HI.appservice-stored-proc-parser --ado-pipeline \\appservice-stored-proc-parser --service-connection-id 6dc4r80d-4143-4813-8d8d-1a974tb37be2
- The error message was: [2024-03-20 20:41:39] [DEBUG] RESPONSE (Forbidden): {"$id":"1","innerException":null,"message":"The user doesn't have access to the service connection(s) added to this pipeline or they are not found. Names/IDs: 6dc4r80d-4143-4813-8d8d-1a974tb37be2", "typeName": "Microsoft.TeamFoundation.Build.WebApi.AccessDeniedException, Microsoft.TeamFoundation.Build2.WebApi", "typeKey":"AccessDeniedException", "errorCode":0,"eventId":3000}"
- Without asking the client to create 60+ new non-shared service connections, what are our options?
@timrogers
: I know you've moved on from the migration team but have been involved in past discussion on this topic
@jsommer
@mickeygousset

solution described here: https://medium.com/objectsharp/azure-pipelines-shared-service-connections-and-github-82aebf79b4aa

