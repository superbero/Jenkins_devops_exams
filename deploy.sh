#!/bin/bash 

namespaces=('dev' 'prod' 'staging' 'QA')

for namespace in "${namespaces[@]}"
do
kubectl apply -f kubernetes/namespaces/${namespace}.yml
echo "Deploying ${namespace} node"
helm install jenkins-${namespace} jenkins-helm-${namespace} --values=jenkins-helm-${namespace}/values.yaml -n ${namespace}
kubectl get all -n ${namespace}
done