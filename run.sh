#!/bin/bash
# build jenkins image
sudo docker build --force-rm=true -t jenkins_docker .
delete_images=$(sudo docker images -f "dangling=true" -q)
[[ ! -z "${delete_images}" ]] && sudo docker rmi -f ${delete_images} || echo "No images to delete"

# start jenkins container
sudo docker run -d --name="docker_jenkins" -v /var/run/docker.sock:/var/run/docker.sock  -p 8080:8080 -p 50000:50000 jenkins_docker:latest
echo "please wait jenkins to start"
docker_logfile=$(docker inspect --format='{{.LogPath}}' docker_jenkins)

# wait for container start
while :
do
  sleep 2s
  #started=$(sudo fgrep 'Finished Download metadata' ${docker_logfile})
  started=$(sudo fgrep 'Jenkins is fully up and running' ${docker_logfile})
  [[ ! -z "${started}" ]] && break || echo "continue...."
done

# get cli jar
#curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# add user ops
echo "adding user ops..."
pass=$(sudo docker exec docker_jenkins cat  /var/jenkins_home/secrets/initialAdminPassword)
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("ops", "ops")' | java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =

# install default plugins
echo "install default plugins"
python install_plugin.py

# stop jenkins for purge logs
echo "purge container log for next monitor jenkins start"
sudo docker stop docker_jenkins
cat /dev/null | sudo tee ${docker_logfile}
sudo docker start docker_jenkins

# wait for jenkins start
while :
do
  sleep 2s
  started=$(sudo fgrep 'Jenkins is fully up and running' ${docker_logfile})
  [[ ! -z "${started}" ]] && break || echo "continue...."
done
#curl -s -XGET --user ops:ops  http://localhost:8080/job/test2/config.xml -o myjob.xml`
CRUMB=$(curl -s 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u ops:ops)
curl -s -XPOST 'http://localhost:8080/createItem?name=test2' -u ops:ops --data-binary @myjob.xml -H "$CRUMB" -H "Content-Type:text/xml"
