#!/bin/bash

IP_ADDR=`hostname -I|cut -d" " -f 1`

kubectl='/usr/local/bin/k3s kubectl'

echo "creating ingress"

cat <<EOF | $kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nova-idc
spec:
  selector:
    app.kubernetes.io/instance: splunk-nova-idc-indexer
  ports:
    - protocol: TCP
      port: 8088
      targetPort: 8088
      name: hec
    - protocol: TCP
      port: 9997
      targetPort: 9997
      name: s2s
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: ${IP_ADDR}
EOF

cat <<EOF | $kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nova-shc
spec:
  selector:
    app.kubernetes.io/instance: splunk-nova-shc-search-head
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
      name: ui
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: ${IP_ADDR}
EOF

cat <<EOF | $kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nova-cm
spec:
  selector:
    app.kubernetes.io/instance: splunk-nova-cm-cluster-master
  ports:
    - protocol: TCP
      port: 8001
      targetPort: 8000
      name: cm
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: ${IP_ADDR}
EOF

cat <<EOF | $kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nova-mc
spec:
  selector:
    app.kubernetes.io/instance: splunk-default-monitoring-console
  ports:
    - protocol: TCP
      port: 8002
      targetPort: 8000
      name: cm
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: ${IP_ADDR}
EOF

echo "==========endpoints==========="

echo "Search Head UI at: http://${IP_ADDR}:8000"
echo "HEC endpoint at: https://${IP_ADDR}:8088"
echo "S2S at: ${IP_ADDR}:9997"
echo "Cluster Master at: http://${IP_ADDR}:8001"
echo "Monitoring Console at: http://${IP_ADDR}:8002"


echo ""
echo "Happy Splunking!!!"