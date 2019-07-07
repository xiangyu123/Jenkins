# build jenkins image
sudo docker build --force-rm=true -t jenkins_docker .
sudo docker rmi -f $(docker images -f "dangling=true" -q)

# start jenkins container
sudo docker run -d --name="docker_jenkins" -v /var/run/docker.sock:/var/run/docker.sock  -p 8080:8080 -p 50000:50000 jenkins_docker:latest
echo "please wait 30 seconds to start jenkins"
sleep 30 # wait jenkins starts

# get jenkins-cli.jar
pass=$(docker exec docker_jenkins cat  /var/jenkins_home/secrets/initialAdminPassword)
#curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("ops", "ops")' | java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =
python install_plugin.py
#curl -s -XGET --user ops:ops  http://localhost:8080/job/test2/config.xml -o myjob.xml`
CRUMB=$(curl -s 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u ops:ops)
curl -s -XPOST 'http://localhost:8080/createItem?name=test2' -u ops:ops --data-binary @myjob.xml -H "$CRUMB" -H "Content-Type:text/xml"
