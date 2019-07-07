# build jenkins image
docker build --force-rm=true -t jenkins_docker .
docker rmi -f $(docker images -f "dangling=true" -q)

# start jenkins container
docker run -d --name="docker_jenkins" -v /var/run/docker.sock:/var/run/docker.sock  -p 8080:8080 -p 50000:50000 jenkins_docker:latest
sleep 30 # wait jenkins starts

# get jenkins-cli.jar
pass=$(docker exec docker_jenkins cat  /var/jenkins_home/secrets/initialAdminPassword)
#curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("ops", "ops")' | java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =
