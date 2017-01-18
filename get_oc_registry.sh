#!/bin/bash

echo "Login into OpenShift as system:admin via sudo."
sudo oc login -u system:admin
echo "Check whoami in OpenShift."
user=$(sudo oc whoami)
if [[ x"$user" != "xsystem:admin" ]]; then
    echo "You are not login as system:admin. Something fails. $user"
    exit 0
fi

echo "Get output of command `sudo oc get svc -n default | grep docker-registry`"
docker_registry=$(sudo oc get svc -n default | grep docker-registry)
if [[ $? -ne 0 ]]; then
    echo "Command failed. $docker_registry"
    exit 1
fi
echo "Output:\n$docker_registry"
IP=$(echo $docker_registry | cut -d' ' -f2)

echo "Login back as developer. Enter developer password:"
sudo oc login -u developer

echo "Enter your email address and press [ENTER]:"
read email

echo "Join local docker register with OpenShift docker-register."
cmd="sudo docker login -u developer -p $(sudo oc whoami -t) -e $email $IP:5000"
echo "Running command: $cmd"
$cmd
if [[ $? -ne 0 ]]; then
    echo "command sudo docker login -u developer -p $(sudo oc whoami -t) -r $email $IP:5000 failed."
    exit 1
fi
echo "OpenShift docker-registry IP address is: $IP"
exit 0
