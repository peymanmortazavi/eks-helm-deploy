#!/usr/bin/env bash

initialize () {
    # Login to Kubernetes Cluster.
    UPDATE_KUBECONFIG_COMMAND="aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
    if [ -n "$CLUSTER_ROLE_ARN" ]; then
        UPDATE_KUBECONFIG_COMMAND="${UPDATE_KUBECONFIG_COMMAND} --role-arn=${CLUSTER_ROLE_ARN}"
    fi
    ${UPDATE_KUBECONFIG_COMMAND}

    # Helm Dependency Update
    helm dependency update ${DEPLOY_CHART_PATH:-helm/}
}

helm_install_or_diff () {
    # Helm Deployment
    if [ "$DIFF" = true ]; then
        UPGRADE_COMMAND="helm diff upgrade --color --wait --atomic --install --timeout ${TIMEOUT}"
    else
        UPGRADE_COMMAND="helm upgrade --wait --atomic --install --timeout ${TIMEOUT}"
    fi

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
}

helm_uninstall () {
    # Uninstall the Helm chart.

    # `diff uninstall` doesn't exist.  Just do a regular dry-run in that case
    if [ "$DIFF" = true ]; then
        DRY_RUN="$DIFF"
    fi

    UNINSTALL_COMMAND="helm uninstall --wait --atomic --timeout ${TIMEOUT}"
    if [ -n "$DEPLOY_NAMESPACE" ]; then
        UNINSTALL_COMMAND="${UNINSTALL_COMMAND} -n ${DEPLOY_NAMESPACE}"
    fi
    if [ "$DEBUG" = true ]; then
        UNINSTALL_COMMAND="${UNINSTALL_COMMAND} --debug"
    fi
    if [ "$DRY_RUN" = true ]; then
        UNINSTALL_COMMAND="${UNINSTALL_COMMAND} --dry-run"
    fi
    UNINSTALL_COMMAND="${UNINSTALL_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH:-helm/}"
    echo "Executing: ${UNINSTALL_COMMAND}"
    ${UNINSTALL_COMMAND}
}

initialize
if [ "$UNINSTALL" = true]; then
    helm_uninstall
else
    helm_install_or_diff
fi