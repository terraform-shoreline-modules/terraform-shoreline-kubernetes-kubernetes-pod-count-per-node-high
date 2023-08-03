
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Pod count per node high
---

This incident type is related to high pod count per node in a Kubernetes cluster. This can happen due to various reasons such as misconfigurations, resource constraints, or issues with the application itself. The incident can cause service disruptions or outages if not addressed in a timely manner. It requires investigation and resolution by the DevOps team to ensure proper functioning of the Kubernetes cluster and the applications running on it.

### Parameters
```shell
# Environment Variables

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export NODE_NAME="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"

```

## Debug

### List all nodes in the cluster
```shell
kubectl get nodes
```

### Check the pod count per node
```shell
kubectl get nodes -o json | jq '.items[] | {name:.metadata.name} + {pods:.status.capacity.pods}'
```

### Check the status of the pods
```shell
kubectl get pods -n ${NAMESPACE}
```

### Check the logs of a pod
```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE}
```

### Check the metrics for the node
```shell
kubectl top node ${NODE_NAME}
```

## Repair

### Define variables
```shell
NODE_SELECTOR="PLACEHOLDER"

POD_SELECTOR="PLACEHOLDER"

DESIRED_REPLICAS="PLACEHOLDER"
```
### Check the deployment status
```shell
kubectl rollout status deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE}
```

### Scale down the pods
```shell
kubectl scale deployment --replicas=$DESIRED_REPLICAS -n ${NAMESPACE} -l $POD_SELECTOR
```

### Wait for pods to terminate
```shell
while [[ $(kubectl get pods -n ${NAMESPACE} -l $POD_SELECTOR -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True True" ]]; do sleep 1; done
```

### Identify and terminate any unnecessary or redundant pods running on the nodes.
```shell
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


```