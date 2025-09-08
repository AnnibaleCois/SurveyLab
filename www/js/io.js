/* Input/output scripts, v 3.0, 18/09/2024 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/

/*  Initialise */

server1 = "http://localhost:8000/";                         // LOcal R database   

/* Read/write users database  */

function readData(user,type,town,sample) { // read samples selected by the user
  request = new XMLHttpRequest();
  request.open('GET', server1 + "v2/readSamples?user=" + user + "&type=" + type + "&town=" + town + "&sample=" + sample, false); //  synchronous request
  request.send(null);
  if (request.status === 200) {
    data =  JSON.parse(request.responseText);
    return(data); 
  }
}; 

function saveData(user,type,town,sample) { // save samples selected by the user
  request = new XMLHttpRequest();
  request.open('POST', server1 + "v2/saveSamples?user=" + user + "&type=" + type + "&town=" + town + "&sample=" + sample, false); //  synchronous request
  request.send(null);
  if (request.status === 200) {
    data =  JSON.parse(request.responseText);
    return(data); 
  }
};

function saveQuest(usercode, quest, toolname) { // save questionnaire defined by the user
  var myHeaders = new Headers();
  myHeaders.append("Content-Type", "application/json");
  myHeaders.append("Authorization", "Basic QWRtaW46aGFycGlhY2xhdDIwMjNAc1Vu");

  var raw = JSON.stringify({
    "operation": "search_by_value","schema": "surveylab2","table": "tools",
    "get_attributes": ["id"],
    "search_attribute": "user",
    "search_value": usercode,
   });
  var requestOptions = {method: 'POST',headers: myHeaders,body: raw,redirect: 'follow'};
  fetch(server3, requestOptions)
    .then(response => response.text())
    .then(result => { 
      if (result != "[]") {
        output = JSON.parse(result)[0].id;
        raw = JSON.stringify({"operation": "update","schema": "surveylab2","table": "tools","records": [{"id": output,"quest": quest, "tool": toolname}]});
      } else {
        raw = JSON.stringify({"operation": "insert","schema": "surveylab2","table": "tools","records": [{"user": usercode,"quest": quest, "tool": toolname}]});
      }  
      requestOptions = {method: 'POST',headers: myHeaders,body: raw,redirect: 'follow'};
      fetch(server3, requestOptions)
    })
    .catch(error => console.log('error', error));
}; 

function readQuest(user) { // read questionnaire defined by the user
  request = new XMLHttpRequest();
  request.open('POST', server1 + "v2/useritems?user=" + user, false); //  synchronous request
  request.send(null);
  if (request.status === 200) {
    cdata =  JSON.parse(request.responseText)[0];
  }
  request = new XMLHttpRequest();
  request.open('GET', server1 + "v2/items1", false); //  synchronous request
  request.send(null);
  if (request.status === 200) {
    qitems =  JSON.parse(request.responseText);
  }
  items = qitems[0];
  types = qitems[1];
    
  let items1 = [];
  let types1 = [];
  for (let i = 0; i < items.length; i++) {
    if (cdata.includes(items[i]) ) {
      items1.push(items[i]);
      types1.push(types[i]);
    }
  }
  stats = getStats(cdata);
  const data = {};
  data.items = items1;
  data.types = types1;
  data.qnum = stats.qnum;
  data.mnum = stats.mnum;
  data.qtime = stats.qtime;
  return(data); 
}; 


