#!/bin/bash
DAPADMINUSERNAME='host%2F'$1
DAPADMINPASSWORD=$2
ACCOUNT=$3
DAPIP=$4
POLICIES_LIST=($(ls policy_code))

#Usage: policy.sh <dapadmin> <dappassword> <dapaccount> <dapip> <policies: root cicd conjur-follower>

main(){
  echo "Loading Policies"
  echo "-----"
  echo $POLICIES_LIST
  loadpolicy
}

authenticate(){
  AUTH=$(curl -ksS -H 'Content-Type: text/plain' -X POST --data "$DAPADMINPASSWORD" "https://$DAPIP/authn/$ACCOUNT/$DAPADMINUSERNAME/authenticate")
  AUTH_TOKEN=$(echo -n $AUTH | base64 -w 0)
  echo "$AUTH_TOKEN"
}

loadpolicy(){
  echo "Authenticating as $DAPADMINUSERNAME with password $DAPADMINPASSWORD. (This should all be hidden)"
  echo "-----"
  local AUTH_TOKEN=$(authenticate)
  for policy in "${POLICIES_LIST[@]}"
  do
    echo -e "\nLoading Policy $policy\n"
    echo "\"$policy\""
    curl -ksS -X POST -H "Authorization: Token token=\"$AUTH_TOKEN\"" --data-binary "@./policy_code/$policy" https://$DAPIP/policies/$ACCOUNT/policy/root
    echo -e "\n"
  done
}

main
