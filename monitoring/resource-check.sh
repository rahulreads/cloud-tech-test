#!/bin/bash

set -euo pipefail

echo "Node Resource Utilization:"
kubectl top nodes

echo "Pod Resource Utilization:"
kubectl top pods --all-namespaces

echo "Resource Utilization for Pods with label 'k8s-app=kube-Devops':"
kubectl top pods --all-namespaces --selector=k8s-app=kube-Devops
