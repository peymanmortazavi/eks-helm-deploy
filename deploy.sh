#!/usr/bin/env bash

# Login to Kubernetes Cluster.
aws eks \
    --region ${AWS_REGION:-us-west-2} \
    update-kubeconfig --name ${CLUSTER_NAME:-blackbox}
    --role-arn=${CLUSTER_ROLE_ARN:-arn:aws:iam::118196747825:role/blackbox-eks-admin}

# Helm Deployment
UPGRADE_COMMAND="helm upgrade --wait --atomic --install"
for config_file in ${DEPLOY_CONFIG_FILES//,/ }
do
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -f ${config_file}"
done
if [ -n "$DEPLOY_NAMESPACE" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi
if [ -n "$DEPLOY_VALUES" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --set ${DEPLOY_VALUES}"
fi
UPGRADE_COMMAND="${UPGRADE_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH:-helm/}"
echo "Executing: ${UPGRADE_COMMAND}"
${UPGRADE_COMMAND}
