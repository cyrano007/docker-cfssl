#! /usr/bin/env bash
set -x

DOCKERFILE='dockerfile'
CA_NAME='cfssl-ca'
CERT_SCRIPT='testcerts.sh'


### Create the CA Key and Certificate for signing Client Certs
# openssl genrsa -des3 -out ca-key.key 4096
# openssl req -new -x509 -days 365 -key ca-key.key -out ca.pem

### Delete passphrate from key
# openssl rsa -in ca-key.key -out ca-key.pem

#########################################################################################################
################################### Build dockerfile    #################################################
#########################################################################################################
rm ${DOCKERFILE}
cat <<EOF > ${DOCKERFILE}
FROM cfssl/cfssl:latest

ADD ca.pem /etc/cfssl/ca.pem
ADD ca-key.pem /etc/cfssl/ca-key.pem

EXPOSE 8888

ENTRYPOINT ["cfssl"]

CMD ["serve","-ca=/etc/cfssl/ca.pem","-ca-key=/etc/cfssl/ca-key.pem","-address=0.0.0.0"]

EOF

#########################################################################################################
################################### Build Dockerimage   #################################################
#########################################################################################################

docker build -t ${CA_NAME} .

#########################################################################################################
################################### running Dockerimage   #################################################
#########################################################################################################
docker rm $(docker stop $(docker ps -a -q --filter ancestor=${CA_NAME} --format="{{.ID}}"))
docker run -d -p 8888:8888 ${CA_NAME}
sleep 5
#########################################################################################################
################################### generate certificate  ###############################################
#########################################################################################################

rm ${CERT_SCRIPT}
cat <<EOF > ${CERT_SCRIPT}
#!/bin/bash
set -x
certname=test.server.org
caaddress='192.168.192.244'

# Generate Certificate
curl -d '{ "request": {"CN": '\"\$certname\"',"hosts":['\"\$certname\"'], "key": { "algo": "rsa","size": 2048 }, "names": [{"C":"DE","ST":"Hessen", "L":"Wiesbaden","O":"poolix.org"}] }}' http://localhost:8888/api/v1/cfssl/newcert > tmpcert.json


# Create Private Key
echo -e "\$(cat tmpcert.json | python -m json.tool |   grep private_key | cut -f4 -d '"')"   > ./\$certname.key

# Create Certificate
echo -e "\$(cat tmpcert.json | python -m json.tool |   grep -m 1 certificate | cut -f4 -d '"')"   > ./\$certname.cer

# Create Certificate Request
echo -e "\$(cat tmpcert.json | python -m json.tool |   grep certificate_request | cut -f4 -d '"')" > ./\$certname.csr

# Remove JSON Data
rm -Rf tmpcert.json  

EOF

bash ./${CERT_SCRIPT}
