#!/usr/bin/env bash

# Login to Kubernetes Cluster.
UPDATE_KUBECONFIG_COMMAND="aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
if [ -n "$CLUSTER_ROLE_ARN" ]; then
    UPDATE_KUBECONFIG_COMMAND="${UPDATE_KUBECONFIG_COMMAND} --role-arn=${CLUSTER_ROLE_ARN}"
fi
${UPDATE_KUBECONFIG_COMMAND}

# Helm Dependency Update
helm dependency update ${DEPLOY_CHART_PATH:-helm/}

# Helm Deployment
UPGRADE_COMMAND="helm upgrade --wait --atomic --install --timeout ${TIMEOUT}"
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
if [ "$DEBUG" = true ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --debug"
fi
if [ "$DRY_RUN" = true ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --dry-run"
fi
UPGRADE_COMMAND="${UPGRADE_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH:-helm/}"
echo "Executing: ${UPGRADE_COMMAND}"
${UPGRADE_COMMAND}
