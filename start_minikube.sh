minikube start  --kubernetes-version v1.7.4 --extra-config=apiserver.Features.EnableSwaggerUI=true --cpus 4 --memory 8192 --extra-config=apiserver.GenericServerRunOptions.AuthorizationMode=RBAC --extra-config=apiserver.GenericServerRunOptions.AuthorizationRBAC,SuperUser=minikube
 
