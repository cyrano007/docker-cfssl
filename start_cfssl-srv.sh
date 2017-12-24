##### Openstack Network
SSH_KEY=~/.ssh/ost
OST_PRJ_NAME="Docker-SRV"
OST_NET="NET-${OST_PRJ_NAME}"
OST_SUBNET="SUBNET-${OST_PRJ_NAME}"
OST_ROUTER="RTR-${OST_PRJ_NAME}"
OST_SEC_GROUP="SEC-${OST_PRJ_NAME}"
OST_IMAGE=76f5f4aa-a78f-4703-b738-cab967957431

docker build -t cfssltest .
docker run -d -p 8888:8888 cfssltest

openstack security group rule create --proto tcp --dst-port 22 ${OST_SEC_GROUP}

curl -d '{ "request": {"hosts":["certname-test"], \  
"names":[{"C":"US", "ST":"California", "L":"San Francisco", "O":"example.com"}]} }' \
http://localhost:8888/api/v1/cfssl/newcert  
