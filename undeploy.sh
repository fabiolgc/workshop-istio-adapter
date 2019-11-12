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

echoBold 'Delete HTTPBin Microservice'
kubectl delete -f wso2am-istio-1.0/samples/httpbin/httpbin.yaml
kubectl delete -f wso2am-istio-1.0/samples/httpbin/httpbin-gw.yaml

echoBold 'Delete Istio Mixer Adapter'
kubectl delete secret generic server-cert --from-file=./wso2am-istio-1.0/install/adapter-artifacts/server.pem -n istio-system
kubectl delete -f wso2am-istio-1.0/install/adapter-artifacts/

echoBold 'Delete WSO2 API Manager and Analytics' 
kubectl delete -f wso2am-istio-1.0/install/analytics/k8s-artifacts/
kubectl delete configmap apim-conf --from-file=./wso2am-istio-1.0/install/api-manager/resources/conf/ -n wso2
kubectl delete configmap apim-lifecycles --from-file=./wso2am-istio-1.0/install/api-manager/resources/lifecycles/ -n wso2
kubectl delete -f wso2am-istio-1.0/install/api-manager/k8s-artifacts/

echoBold 'Delete Istio'
for i in istio-1.3.4/install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl delete -f $i; done
kubectl delete -f istio-1.3.4/install/kubernetes/istio-demo.yaml

echoBold 'Finished: Start playing with all this nice stuff'