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
for i in istio-1.3.4/install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
kubectl apply -f istio-1.3.4/install/kubernetes/istio-demo.yaml

echoBold 'Installing WSO2 API Manager and Analytics' 
kubectl apply -f wso2am-istio-1.0/install/analytics/k8s-artifacts/
kubectl create configmap apim-conf --from-file=./wso2am-istio-1.0/install/api-manager/resources/conf/ -n wso2
kubectl create configmap apim-lifecycles --from-file=./wso2am-istio-1.0/install/api-manager/resources/lifecycles/ -n wso2
kubectl apply -f wso2am-istio-1.0/install/api-manager/k8s-artifacts/

echoBold 'Installing Istio Mixer Adapter'
kubectl create secret generic server-cert --from-file=./wso2am-istio-1.0/install/adapter-artifacts/server.pem -n istio-system
kubectl apply -f wso2am-istio-1.0/install/adapter-artifacts/
#sleep 5s

echoBold 'Enable Istio Sidecar Injection'
kubectl label namespace default istio-injection=enabled

echoBold 'Deploy HTTPBin Microservice'
kubectl create -f wso2am-istio-1.0/samples/httpbin/httpbin.yaml
kubectl create -f wso2am-istio-1.0/samples/httpbin/httpbin-gw.yaml

echoBold 'Finished: Start playing with all this nice stuff'
