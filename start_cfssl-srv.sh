docker build -t cfssltest .
docker run -d -p 8888:8888 cfssltest



# RUN cfssl print-defaults config > ca-config.json \
# && cfssl print-defaults csr > ca-csr.json \
# && cfssl genkey -initca ca-csr.json | cfssljson -bare ca
#


# CMD ["serve","-ca=ca.pem","-ca-key=ca-key.pem","-address=0.0.0.0"]

curl -d '{ "request": {"hosts":["certname-test"], \
"names":[{"C":"US", "ST":"California", "L":"San Francisco", "O":"example.com"}]} }' \
http://localhost:8888/api/v1/cfssl/newcert
