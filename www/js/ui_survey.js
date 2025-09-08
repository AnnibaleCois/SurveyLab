/* User interface scripts - survey page, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

// Page load

function updateSurvey(){
  nhsampled = 0;
  nisampled = 0;
  sam_currentSample_tlist.forEach(function(town) {
   if (survey_collected.includes(parseInt(town))) {
     nhsampled = nhsampled + sam_currentSample_hsize[town];
     nisampled = nisampled + sam_currentSample_isize[town];
   }
  });
  nhsampledp = Math.round(nhsampled/sam_currentSample_thsize*100);
  nisampledp = Math.round(nisampled/sam_currentSample_tisize*100);
  if (nhsampledp > 100) {nhsampledp = 100 + "%";} else {nhsampledp = nhsampledp + "%"}
  if (nisampledp > 100) {nisampledp = 100 + "%";} else {nisampledp = nisampledp + "%"}

  document.getElementById("hprogress").style.width = nhsampled;
  document.getElementById("iprogress").style.width = nisampled;
  document.getElementById("hprogress").innerHTML = nhsampledp;
  document.getElementById("iprogress").innerHTML = nisampledp;
  document.getElementById("surveyer").style.display = "bloc";

  if (nhsampled == 0) {
    let sec = "";
    sam_currentSample_tlist.forEach(function(elem) {
      if (elem > 0) {
      tname = envir_towns.Town_Name[elem];
      sec = sec +  
        '<div class="f1"><div class="f2a" id="drag' + elem + '" ondrop="drop(event);" ondragover="allowDrop(event);"></div><div class="f3"><div class="f4">' + tname + '</div>HH:<span id="h' + elem + '">' + sam_currentSample_hsize[elem] + '</span><br/>In: <span id="i' + elem +'">' + sam_currentSample_isize[elem] +'</span></div><h6 class="f5b" id="n' + elem + 
        '"></h6></div>';
      }
    });
    document.getElementById("sampledtowns").innerHTML = sec;
    document.getElementById("reset_survey").disabled = true;
    document.getElementById("download_survey").disabled = true;
    document.getElementById("upload_survey").disabled = true;
  } else {
    let sec = "";
    sam_currentSample_tlist.forEach(function(elem) {
      if (elem > 0) {
        tname = envir_towns.Town_Name[elem];
        if (survey_collected.includes(parseInt(elem))) {
          sec = sec +  
            '<div class="f1"><div class="f2b" id="drag' + elem + '" ondrop="drop(event);" ondragover="allowDrop(event);"></div><div class="f3"><div class="f4">' + tname + '</div>HH:<span id="h' + elem + '">' + sam_currentSample_hsize[elem] + '</span><br/>In: <span id="i' + elem +'">' + sam_currentSample_isize[elem] +'</span></div><h6 class="f5b" id="n' + elem + 
            '"></h6></div>';
        } else {
        sec = sec +  
            '<div class="f1"><div class="f2a" id="drag' + elem + '" ondrop="drop(event);" ondragover="allowDrop(event);"></div><div class="f3"><div class="f4">' + tname + '</div>HH:<span id="h' + elem + '">' + sam_currentSample_hsize[elem] + '</span><br/>In: <span id="i' + elem +'">' + sam_currentSample_isize[elem] +'</span></div><h6 class="f5b" id="n' + elem + 
            '"></h6></div>';
        }
      }
    });
    document.getElementById("sampledtowns").innerHTML = sec;
    document.getElementById("reset_survey").disabled = false;
    document.getElementById("download_survey").disabled = false;
    if (eupload == 1) { 
       document.getElementById("upload_survey").disabled = false; 
    }
  }
}

// MAnual collection (Drag & Drop) 

function allowDrop(ev) {
  ev.preventDefault();
}

function drag(ev) {
  ev.dataTransfer.setData("text", ev.target.id);
}

function drop(ev) {
  ev.preventDefault();
  var data = ev.dataTransfer.getData("text");
  
  // Option1 : Drops the surveyer image 
  //var nodeCopy = document.getElementById(data).cloneNode(true);
  //ev.target.appendChild(nodeCopy);
  
  // Option 2: Drops the maicos image
  var newImg = document.createElement("img");
  newImg.src = "img/mapicons.png";  
  ev.target.appendChild(newImg);

  ev.stopPropagation();
  tar = $(event.target).attr('id');
  to = parseInt(tar.substring(4));
  let stime = itemtime*sam_currentSample_isize[to]*(qqprogress*tool_qnum + qmprogress*tool_mnum);
  survey_collected.push(to);
  document.getElementById("surveyer").style.display ="none"; 
  document.getElementById("surveyer_busy").style.display = "block"; 
  document.getElementById(tar).style= "-webkit-filter: drop-shadow(5px 5px 5px #222); filter:drop-shadow(5px 5px 5px #222); background:rgba(0,0,0,0);";
  document.getElementById("surveyprogress").style="display:block";
  ev.target.ondrop = "";
  ev.target.ondragover = "";
  var end = false;
  let imgref = $(event.target).children()[0];   // reference to the dropped image
  
  nhsampled = nhsampled + sam_currentSample_hsize[to];
  nisampled = nisampled + sam_currentSample_isize[to];
  nhsampledp = Math.round(nhsampled/sam_currentSample_thsize*100);
  nisampledp = Math.round(nisampled/sam_currentSample_tisize*100);
  if (nhsampledp > 100) {nhsampledp = 100 + "%";} else {nhsampledp = nhsampledp + "%"}
  if (nisampledp > 100) {nisampledp = 100 + "%";} else {nisampledp = nisampledp + "%"}
  document.getElementById("hprogress").style.width =nhsampled; 
  document.getElementById("iprogress").style.width =nisampled; 
  document.getElementById("hprogress").innerHTML = nhsampledp; 
  document.getElementById("iprogress").innerHTML = nisampledp; 
  document.getElementById("surveyer").style.display ="block"; 
  document.getElementById("surveyer_busy").style.display = "none"; 
  document.getElementById("reset_survey").disabled = false;
  document.getElementById("download_survey").disabled = false;
  if (eupload == 1) { 
     document.getElementById("upload_survey").disabled = false; 
  }
  Shiny.setInputValue('survey_collected', survey_collected);
  
  // Collect data and prepare output dataset (Server) 
  const strig = JSON.parse(JSON.stringify(survey_collected));
  let num = Math.random();
  num = Math.round(num*num*1000 + 200);
  strig.push(num);
  Shiny.setInputValue("survey_collect_trigger", strig);

  return false;
}

// Bulk collection 

function allCollection() {
  
  document.getElementById("surveyprogress").style.visibility = "hidden";
  document.getElementById("surveyspinner").style.visibility = "visible";
  $('.sidebar-menu a').addClass('inactiveItem'); 
  
  // Manage the interface (only visuals, does not collect data)
  
  resetCollection();
  
  i = 0; 
  niter = sam_currentSample_tlist.length;
  
  function surveyLoop() {    
    document.getElementById("surveyer").style.display ="none"; 
    document.getElementById("surveyer_busy").style.display = "block"; 
    
    setTimeout(function() {   
       x = document.getElementById("drag" + sam_currentSample_tlist[i]);
       x.style.background = "url('img/mapicons.png') center no-repeat";
       nhsampled = nhsampled + sam_currentSample_hsize[sam_currentSample_tlist[i]];
       nisampled = nisampled + sam_currentSample_isize[sam_currentSample_tlist[i]];
       nhsampledp = Math.round(nhsampled/sam_currentSample_thsize*100);
       nisampledp = Math.round(nisampled/sam_currentSample_tisize*100);
       if (nhsampledp > 100) {nhsampledp = 100 + "%";} else {nhsampledp = nhsampledp + "%"}
       if (nisampledp > 100) {nisampledp = 100 + "%";} else {nisampledp = nisampledp + "%"}    
       document.getElementById("hprogress").style.width = nhsampled;
       document.getElementById("iprogress").style.width = nisampled;
       document.getElementById("hprogress").innerHTML = nhsampledp;
       document.getElementById("iprogress").innerHTML = nisampledp;

       if (nisampled/sam_currentSample_tisize > 0.99) {
         i = niter;
       }
      
       i++;                    
       if (i < niter) {           
         surveyLoop();             
       }  else {
          document.getElementById("surveyer").style.display ="block"; 
          document.getElementById("surveyer_busy").style.display = "none";
          document.getElementById("reset_survey").disabled = false;
          document.getElementById("download_survey").disabled = false;
          if (eupload == 1) { 
            document.getElementById("upload_survey").disabled = false; 
          }
          document.getElementById("hprogress").innerHTML = "100%";
          document.getElementById("iprogress").innerHTML = "100%";
          document.getElementById("hprogress").style.width = "100%";
          document.getElementById("iprogress").style.width = "100%";
       }                     
    }, 500*tool_qtime/tool_qscale)
  }
  surveyLoop(); 
  
    // Collect data and prepare output dataset (Server)

  survey_collected = [];
  sam_currentSample_tlist.forEach(function(elem) {
      if (elem > 0) {
        survey_collected.push(parseInt(elem));
      }
    });
  Shiny.setInputValue("survey_collected", sam_currentSample_tlist);  
  const strig = JSON.parse(JSON.stringify(sam_currentSample_tlist));
  let num = Math.random();
  num = Math.round(num*num*1000 + 200);
  strig.push(num);
  Shiny.setInputValue("survey_collect_trigger", strig);

} 

// Other  

function resetCollection() {
   survey_collected = [];
   Shiny.setInputValue('survey_collected', "");
   Shiny.setInputValue('survey_collect_trigger', Math.random());
   updateSurvey();    
}

