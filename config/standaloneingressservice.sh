#!/bin/bash

IP_ADDR=`hostname -I|cut -d" " -f 1`

kubectl='/usr/local/bin/k3s kubectl'

echo "creating ingress"

cat <<EOF | $kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nova-s1-ingress
spec:
  selector:
    app.kubernetes.io/instance: splunk-nova-s1-standalone
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
      name: ui
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

echo "==========endpoints==========="

echo "Standalone UI at: http://${IP_ADDR}:8000"
echo "HEC endpoint at: https://${IP_ADDR}:8088"
echo "S2S at: ${IP_ADDR}:9997"

echo ""
echo "Happy Splunking!!!"
