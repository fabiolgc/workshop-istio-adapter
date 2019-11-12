set -e

ECHO=`which echo`
GREP=`which grep`
KUBERNETES_CLIENT=`which kubectl`
SED=`which sed`
TEST=`which test`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}




echoBold 'Installing Istio'
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
kubectl apply -f install/kubernetes/istio-demo.yaml

echoBold 'Installing WSO2 API Manager and Analytics'
cd wso2am-istio-1.0
kubectl apply -f install/analytics/k8s-artifacts/
kubectl create configmap apim-conf --from-file=./install/api-manager/resources/conf/ -n wso2
kubectl create configmap apim-lifecycles --from-file=./install/api-manager/resources/lifecycles/ -n wso2
kubectl apply -f install/api-manager/k8s-artifacts/

echoBold 'Installing Istio Mixer Adapter'
kubectl create secret generic server-cert --from-file=./install/adapter-artifacts/server.pem -n istio-system
kubectl apply -f install/adapter-artifacts/
#sleep 5s

echoBold 'Enable Istio Sidecar Injection'
kubectl label namespace default istio-injection=enabled

echoBold 'Deploy HTTPBin Microservice'
kubectl create -f samples/httpbin/httpbin.yaml
kubectl create -f samples/httpbin/httpbin-gw.yaml

echoBold 'Finished: Start playing with all this nice stuff'
