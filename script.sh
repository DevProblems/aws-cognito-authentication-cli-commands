#!/bin/bash
read -p "Enter your username, password and groupname: " username password groupname

echo 

echo "user ${username} signing-up"
signupresult=$(aws cognito-idp sign-up --client-id "CLIENT_ID" --username "${username}" --password "${password}")
echo "cognitoId: $(jq '.UserSub' <<< "${signupresult}")"

echo

echo "user ${username} getting confirmed in the cognito"
confirmsignup=$(aws cognito-idp admin-confirm-sign-up --user-pool-id "USER_POOL_ID" --username "${username}")

echo 

echo "adding user to group: ${groupname}"
addusertogroupresult=$(aws cognito-idp admin-add-user-to-group --user-pool-id "USER_POOL_ID" --username "${username}" --group-name "${groupname}")

echo 

echo "user ${username} signing-in"
signinresult=$(aws cognito-idp admin-initiate-auth --user-pool-id "USER_POOL_ID" --client-id "CLIENT_ID" --auth-flow "ADMIN_NO_SRP_AUTH" --auth-parameters USERNAME="${username}",PASSWORD="${password}")
IdToken=$(jq '.AuthenticationResult.IdToken' <<< "${signinresult}")
echo "IdToken: ${IdToken}"

echo

echo "user ${username} getting identity-id"
getidresult=$(aws cognito-identity get-id --account-id "ACCOUNT_ID" --identity-pool-id "IDENTITY_POOL_ID" --logins "cognito-idp.REGION.amazonaws.com/USER_POOL_ID"="${IdToken}")
IdentityId=$(jq -r '.IdentityId' <<< "${getidresult}")
echo "IdentityId : ${IdentityId}"

echo

echo "user ${username} getting credentials"
getcredentialsforidentity=$(aws cognito-identity get-credentials-for-identity --identity-id "${IdentityId}" --logins "cognito-idp.REGION.amazonaws.com/USER_POOL_ID"="${IdToken}")
echo "${getcredentialsforidentity}"	
