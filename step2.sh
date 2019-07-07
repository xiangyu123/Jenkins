#curl -s -XGET --user ops:ops  http://localhost:8080/job/test2/config.xml -o myjob.xml`
CRUMB=$(curl -s 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u ops:ops)
curl -s -XPOST 'http://localhost:8080/createItem?name=test2' -u ops:ops --data-binary @myjob.xml -H "$CRUMB" -H "Content-Type:text/xml"
