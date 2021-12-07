Get the application URL by running these commands:

```bash
export POD_NAME=$(kubectl get pods --namespace robo1-basic -l "app.kubernetes.io/name=robo1-simple,app.kubernetes.io/instance=robo1-basic" -o jsonpath="{.items[0].metadata.name}")

export CONTAINER_PORT=$(kubectl get pod --namespace robo1-basic $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")

echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace robo1-basic port-forward $POD_NAME 8080:$CONTAINER_PORT
```