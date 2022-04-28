#!/usr/bin/env bash
## lkc-o327py

confluent iam service-account create RestProxyCloudAccount --description "My rest proxy account"

# +-------------+-----------------------+
# | ID          | sa-v7dnkn             |
# | Name        | RestProxyCloudAccount |
# | Description | My rest proxy account |
# +-------------+-----------------------+

confluent api-key create --resource  lkc-o327py --service-account sa-v7dnkn

#It may take a couple of minutes for the API key to be ready.
#Save the API key and secret. The secret is not retrievable later.
#+---------+------------------------------------------------------------------+
#| API Key | ZKUVX3P7WVPGK2AO                                                 |
#| Secret  | NZ0u1f74eCD/aoQ7mPo/zpHnu9MZLSIRHviI/iz+G4/ciC5SsSpdYByVOMwXpV6n |
#+---------+------------------------------------------------------------------+


confluent iam rbac role-binding create --principal User:sa-v7dnkn \
                  --role ResourceOwner --resource "Topic:*" \
                  --cloud-cluster lkc-o327py --kafka-cluster-id lkc-o327py \
                  --environment env-j9wgp

confluent iam rbac role-binding create --principal User:sa-v7dnkn \
                  --role ResourceOwner --resource "Group:*" \
                  --cloud-cluster lkc-o327py --kafka-cluster-id lkc-o327py \
                  --environment env-j9wgp

confluent iam rbac role-binding create --principal User:sa-v7dnkn \
                  --role CloudClusterAdmin  \
                  --cloud-cluster lkc-pgk6po \
                  --environment env-j9wgp
