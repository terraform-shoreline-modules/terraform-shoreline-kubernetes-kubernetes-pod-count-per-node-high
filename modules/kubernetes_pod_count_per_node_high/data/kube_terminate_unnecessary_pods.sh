#!/bin/bash

# Set the namespace and node name to check

NAMESPACE=${NAMESPACE}

NODE_NAME=${NODE_NAME}

NECESSARY_LABEL="PLACEHOLDER"

# Get a list of running pods on the specified node

PODS=$(kubectl get pods -n $NAMESPACE -o wide --field-selector spec.nodeName=$NODE_NAME --no-headers | awk '{ print $1 }')

# Loop through each pod and check if it is necessary

for POD_NAME in $PODS

do
  # Get the labels for the pod

  LABELS=$(kubectl get pod -n $NAMESPACE $POD_NAME -o jsonpath='{.metadata.labels}')

  # Check if the pod is necessary based on its labels

  if [[ "$LABELS" != *"${NECESSARY_LABEL}"* ]]; then

    echo "Terminating unnecessary pod $POD_NAME"

    kubectl delete pod -n $NAMESPACE $POD_NAME

  fi

done