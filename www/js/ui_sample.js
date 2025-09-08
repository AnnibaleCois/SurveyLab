/* User interface scripts - town page, v 3.0, 01/08/2024 */
/* Annibale Cois (acois@sun.ac.za)*/    

// Load/change town maps

function replaceSvg(container,town){
    var map = document.getElementById(container);
    var pcont = document.getElementById("parent_world");
    var vis_world = document.getElementById("bworld");
    var vis_town = document.getElementById("btown");
    if (container == "panzoom-element_world") {
      if (town != 0) {
        pcont.style.backgroundColor = tcolors[town-1];
        map.innerHTML = "<img src='./maps/town_" + town + ".svg' onload = 'SVGInject(this, options = {makeIdsUnique: false})'/>";
        Shiny.setInputValue('currentTown_explore', town);
        int_currentTown_explore = town;
        panzoom_world.pan(0,-90);
        panzoom_world.zoom(0.8, { animate: false });
        vis_world.style.display = "none";
        vis_town.style.display = "block";
      } else {
        pcont.style.backgroundColor = "#466EAB";
        map.innerHTML = "<img src='./maps/world.svg' onload = 'SVGInject(this, options = {makeIdsUnique: false})'/>";
        Shiny.setInputValue('currentTown_explore', town);
        int_currentTown_explore = town;
        panzoom_world.pan(-1000, -500);
        panzoom_world.zoom(0.53, { animate: false });
        vis_world.style.display = "block";
        vis_town.style.display = "none";
      }
    } else if (container == "panzoom-element_sample") {
      var pconts = document.getElementById("parent_sample");
      var checkbox_sample = document.getElementById("checkbox_sample_1");
      var bres_sample = document.getElementById("bres_sample");
      var cleartown_sample = document.getElementById("cleartown_sample");
      var random_sample = document.getElementById("random_sample");   
      if (town != 0) {
        Shiny.setInputValue('currentTown_sample', town);        
        int_currentTown_sample = town;
        pconts.style.backgroundColor = tcolors[town-1];
        map.innerHTML = "<img src='./maps/town_" + town + ".svg' onload = 'SVGInject(this, options = {makeIdsUnique: false})'/>"; 
        panzoom_sample.pan(0,-90);
        panzoom_sample.zoom(0.8, { animate: false });
        checkbox_sample.style.display = "block";
        bres_sample.style.display = "block";
        cleartown_sample.style.display = "block"
        random_sample.style.display = "none";
        setTimeout(function(){showhideLabels_sample("init");}, 500);
        setTimeout(function(){showSampledHouseholds();}, 500);
      } else {
        var grid = document.getElementById("msgrid");
        var grid_checkbox = document.getElementById("grid_sample");
        Shiny.setInputValue('currentTown_sample', 0);
        int_currentTown_sample = 0;
        pconts.style.backgroundColor = "#EEF6FB";
        map.innerHTML = "<img src='./maps/sample.svg' onload = 'SVGInject(this, options = {makeIdsUnique: false})'/>"; 
        panzoom_sample.pan(-1000, -500);
        panzoom_sample.zoom(0.53, { animate: false });
        grid.style.visibility = "hidden";        
        grid_checkbox.checked = false;
        checkbox_sample.style.display = "none";
        bres_sample.style.display = "none";
        cleartown_sample.style.display = "none";
        random_sample.style.display = "block";
        setTimeout(function(){showSampledTowns();}, 5000);
      }
    }
};

// Show/hide map elements 

function showhideLabels_sample(x) {
  let y;
  if (document.getElementById("bsub_sample").checked) {
    y = document.getElementById("sulabel");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("sulabel");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("bbui_sample").checked) {
    y = document.getElementById("plabel");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("plabel");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("bnum_sample").checked) {
    y = document.getElementById("flabel");
    y.style.fill = 'rgba(255,255,0,255)';
  } else {
    y = document.getElementById("flabel");
    y.style.fill = 'rgba(0,0,0,0)';
  };
  
  if (document.getElementById("grid_sample").checked) {
    y = document.getElementById("msgrid");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("msgrid");
    y.style.visibility = "hidden";
  };
}
    
function showhideLabels_explore(x) {
  let y;
  if (document.getElementById("bsub_explore").checked) {
    y = document.getElementById("sulabel");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("sulabel");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("bbui_explore").checked) {
    y = document.getElementById("plabel");
    
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("plabel");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("bnum_explore").checked) {
    y = document.getElementById("flabel");
    y.style.fill = 'rgba(255,255,0,255)';
  } else {
    y = document.getElementById("flabel");
    y.style.fill = 'rgba(0,0,0,0)';
  };
}    
    
function resetLabels_sample(x) {
  document.getElementById("bsub_sample").checked = false;
  document.getElementById("bbui_sample").checked = true;
  document.getElementById("bnum_sample").checked = false;
  document.getElementById("grid_sample").checked = true;
  showhideLabels_sample('res');
  showSampledHouseholds();
}       
    
function resetLabels_overview(x) {
  document.getElementById("bsub_sample").checked = false;
  document.getElementById("bbui_sample").checked = false;
  document.getElementById("bnum_sample").checked = false;
  document.getElementById("grid_sample").checked = false;
  showhideLabels_sample('res');
  showSampledHouseholds();
}           
    
function resetLabels_explore(x) {
  document.getElementById("bsub_explore").checked = true;
  document.getElementById("bbui_explore").checked = true;
  document.getElementById("bnum_explore").checked = false;
}   

// Message Handlers  

  // Load/change maps
  
Shiny.addCustomMessageHandler("handler_status_explore",
    function(data) {
     let town = data[0];
     let tstat = data[1];
     let wpop = data[2];
     let whou = data[3];
     
     var etowntitle = document.getElementById("etowntitle");
     var etownregion = document.getElementById("etownregion");
     var etownpop = document.getElementById("etownpop");
    
     if (town != 0) {
      etowntitle.innerHTML = tstat.Town_Name;
      etownregion.innerHTML = "Region: " + tstat.Region_Name;
      etownpop.innerHTML = ", Population: " + tstat.Population + ", Households: " + tstat.Households;
    } else {
      etowntitle.innerHTML = "The SurveyLab world";
      etownregion.innerHTML = "";
      etownpop.innerHTML = "Population: " + wpop + ", Households: " + whou;
    }
  }                               
); 

Shiny.addCustomMessageHandler("handler_status_sample",
    function(data) {
     let town = data[0];
  
     if (town != 0) {
         let tstat = data[1];   
         var ttowntitle = document.getElementById("ttowntitle");
         var ttownregion = document.getElementById("ttownregion");
         var ttownpop = document.getElementById("ttownpop");
         var ttownhsample = document.getElementById('hssize_town');
         var ttownisample = document.getElementById('issize_town');
         var header_sample = document.getElementById('header_images_sample');
         var header_overview = document.getElementById('header_images_overview');
         header_sample.style.display = "block";
         header_overview.style.display = "none";
         ttowntitle.innerHTML = tstat.Town_Name;
         ttownregion.innerHTML = "Region: " + tstat.Region_Name;
         ttownpop.innerHTML = ", Population: " + tstat.Population + ", Households: " + tstat.Households;
         ttownhsample.innerHTML = sam_currentSample_hsize[town];   
         ttownisample.innerHTML = sam_currentSample_isize[town];   
         setTimeout(function(){showSampledHouseholds();}, 500);  // show sampled households
     } else {
         var ttowntitle = document.getElementById("ttowntitle");
         var ttownregion = document.getElementById("ttownregion");
         var ttownpop = document.getElementById("ttownpop");
         var ttownhsample = document.getElementById('hssize_town');
         var ttownisample = document.getElementById('issize_town');
         var header_sample = document.getElementById('header_images_sample');
         var header_overview = document.getElementById('header_images_overview');
         header_sample.style.display = "none";
         header_overview.style.display = "block";
  
         ttowntitle.innerHTML = "Sampling";
         ttownregion.innerHTML = "";
         ttownpop.innerHTML = "" 
         ttownhsample.innerHTML = 1;   
         ttownisample.innerHTML = 2;   
     }
  }                               
);   
  
  // Pull data for popups

Shiny.addCustomMessageHandler("handler_popup_moffice",      
    function(data) {
      let tstat = data[0];
      let sstat = data[1];
      document.getElementById('mtown').innerHTML = tstat.Town_Name;  
      document.getElementById('malt').innerHTML = tstat.Altitude;     
      document.getElementById('mpop').innerHTML = tstat.Population;
      document.getElementById('mhh').innerHTML = tstat.Households;
      document.getElementById('mcap').innerHTML = tstat.Capital;
      document.getElementById('meoff').innerHTML = tstat.Eoffice;
      document.getElementById('mclin').innerHTML = tstat.Mclinic;
      document.getElementById('mhosp').innerHTML = tstat.Hospital;
      document.getElementById('mwea').innerHTML = tstat.Mean_Wealth;
      document.getElementById('mgini').innerHTML = tstat.Gini_Wndex;    
      document.getElementById('mlead').innerHTML = tstat.Mine_lead;
      document.getElementById('mgold').innerHTML = tstat.Mine_gold;
      document.getElementById('mpow').innerHTML = tstat.Powerstation_coal;
      var table = new Tabulator("#msub", {
      data:sstat, //assign data to table
      autoColumns:true //create columns from data field names
    });
    document.getElementById('moffice').style.background = "url('img/moffice_popup.png')";
  }                               
); 

Shiny.addCustomMessageHandler("handler_popup_eoffice",
    function(data) {
      let rstat = data[0];
      let tstat = data[1];  
      document.getElementById('ereg').innerHTML = rstat.Region_Name;  
      document.getElementById('ealt').innerHTML = rstat.Altitude;     
      document.getElementById('etavg').innerHTML = rstat.Temp_avg;
      document.getElementById('etmax').innerHTML = rstat.Temp_max;
      document.getElementById('etmin').innerHTML = rstat.Temp_min;
      document.getElementById('eravg').innerHTML = rstat.Rain_avg;
      document.getElementById('ep25').innerHTML = rstat.PM25;
      var table = new Tabulator("#etowns", {
      data:tstat, //assign data to table
      autoColumns:true //create columns from data field names
      });
      document.getElementById('moffice').style.background = "url('img/eoffice_popup.png')";
      //let statistics = new Array(tstat);
      //document.getElementById('etowns').innerHTML = tableMaker(statistics);
  }                               
); 

Shiny.addCustomMessageHandler("handler_popup_hospital",
    function(data) {
      let hstat = data;
      document.getElementById('hname').innerHTML = hstat.Facility_NAme;  
      document.getElementById('hbeds').innerHTML = hstat.Beds;   
      document.getElementById('hhead').innerHTML = hstat.Headcount;     
      document.getElementById('hdoc').innerHTML = hstat.Doctors;
      document.getElementById('hnur').innerHTML = hstat.Nurses;
      document.getElementById('hser1').innerHTML = hstat.SER_1;
      document.getElementById('hser2').innerHTML = hstat.SER_2;
      document.getElementById('hser3').innerHTML = hstat.SER_3;
      document.getElementById('hser4').innerHTML = hstat.SER_4;
      document.getElementById('hser5').innerHTML = hstat.SER_5;
      document.getElementById('hser6').innerHTML = hstat.SER_6;
      document.getElementById('hser7').innerHTML = hstat.SER_7;
      document.getElementById('hser8').innerHTML = hstat.SER_8;
      document.getElementById('hser9').innerHTML = hstat.SER_9;
      document.getElementById('hospital').style.background = "url('img/hospital_popup.png')";
  }  
  
); 

Shiny.addCustomMessageHandler("handler_popup_clinic",
    function(data) {
      let hstat = data;
      document.getElementById('cname').innerHTML = hstat.Facility_NAme;  
      document.getElementById('hbeds').innerHTML = hstat.Beds;   
      document.getElementById('chead').innerHTML = hstat.Headcount;     
      document.getElementById('cdoc').innerHTML = hstat.Doctors;
      document.getElementById('cnur').innerHTML = hstat.Nurses;
      document.getElementById('cser1').innerHTML = hstat.SER_1;
      document.getElementById('cser2').innerHTML = hstat.SER_2;
      document.getElementById('cser3').innerHTML = hstat.SER_3;
      document.getElementById('cser4').innerHTML = hstat.SER_4;
      document.getElementById('cser5').innerHTML = hstat.SER_5;
      document.getElementById('cser6').innerHTML = hstat.SER_6;
      document.getElementById('cser7').innerHTML = hstat.SER_7;
      document.getElementById('cser8').innerHTML = hstat.SER_8;
      document.getElementById('cser9').innerHTML = hstat.SER_9;
      
      document.getElementById('clinic').style.background = "url('img/clinic_popup.png')";
  }            
); 

  // Pull data on household members

Shiny.addCustomMessageHandler("handler_household_members",
    function(data) {
      let sexlabels = ["Male","Female"];
      let agelabels = ["0-9","10-19","20-39","40-64","65+"];
      data = data[0];
      let members ="";
      let hsize = data.HID.length;  
      int_currentMembers = data.IID;
      if (data.sex[0] != 'NA') {
        for (let me = 0; me < hsize; me++) {
          if (int_currentSampled.includes(int_currentMembers[me])) {
            members = members + "<img id='" + int_currentMembers[me] + "' src='img/member_" + data.sex[me] + "_" + data.popgroup[me] + "_" + data.agecat[me] + 
            ".png' width='40' style='margin-right:3px; cursor:pointer; pointer-events: auto; border: 2px solid red;' title='" + "Sex = " + sexlabels[data.sex[me]-1] +"; Age group = " + agelabels[data.agecat[me]-1] + 
            "' onclick = 'sampleIND(this.id)' />";  
          } else {
            members = members + "<img id='" + int_currentMembers[me] + "' src='img/member_" + data.sex[me] + "_" + data.popgroup[me] + "_" + data.agecat[me] + 
            ".png' width='40' style='margin-right:3px; cursor:pointer; pointer-events: auto;' title='" + "Sex = " + sexlabels[data.sex[me]-1] +"; Age group = " + agelabels[data.agecat[me]-1] + 
            "' onclick = 'sampleIND(this.id)' />";  
         }
        } 
      } else {
        members = "<img src='img/vacant.png' style='margin-right:3px;'></img>";
      }
      if (!(data.HID[0] == null)) {
        document.getElementById('sample').innerHTML = members;
        document.getElementById('hsampled').innerHTML = data.HID[0].split("_")[2];
      }
  }
); 

// Popup Management  

function rstats(regname) {
    Shiny.setInputValue("regionstats", regname);
};

function mstats(town) {
    Shiny.setInputValue("townstats", town);
};

function estats(envirstats) {
    Shiny.setInputValue("envirstats", envirstats);
};

function hstats(facstats) {
    Shiny.setInputValue("hospstats", facstats);
};

function cstats(facstats) {
    Shiny.setInputValue("clinstats", facstats);
};

// Sampling Functions (manual)
  
function addHH(hhid) {
  if (!(int_currentTown_sample == 0)) {
    int_currentHousehold = hhid;
    hhid_h = "H_" + int_currentTown_sample + "_" + hhid.substring(7, hhid.length);
    
    let x1 = document.getElementById(hhid_h);
    flag = !((x1.style.fill == "rgb(0, 0, 0)") || (x1.style.fill == "#000000"));
    int_currentSampled = [];
    if (!flag) {
      for(const sample of sam_currentSample_ilist[int_currentTown_sample]) { 
        if (sample.substring(0,7) == hhid_h) {
          int_currentSampled.push(sample);
        }
      }
    };
    x1.style.fill = "#00FF00";
    x1.style.stroke = "#00FF00";
    document.getElementById("selHous").style.visibility = "visible";
    Shiny.setInputValue('currentHousehold', hhid_h);
  }
}

function selectHH(hhid) {
  hhid_h = "H_" + int_currentTown_sample + "_" + hhid.substring(7, hhid.length);
  let x1 = document.getElementById(hhid_h);
  int_newSampled = [];   
 
  for (const member of int_currentMembers) {                                               // Make a list with the currently sampled household members
    if (document.getElementById(member).style.border == "2px solid red") {
      int_newSampled.push(member);
    }
  }

  for(const member of sam_currentSample_ilist[int_currentTown_sample]) {       // Delete all previously sampled household members for the sample (if any)
    if (member.substring(0,7) == hhid_h) { 
      const index = sam_currentSample_ilist[int_currentTown_sample].indexOf(member);
      sam_currentSample_ilist[int_currentTown_sample].splice(member, 1); 
    }
  }  
    
   for(const household of sam_currentSample_hlist[int_currentTown_sample]) {       // Delete the household from the sample
    if (household == hhid_h) { 
      const index = sam_currentSample_hlist[int_currentTown_sample].indexOf(household);
      sam_currentSample_hlist[int_currentTown_sample].splice(index, 1); 
    }
  }  
  
  int_currentSampled = int_newSampled;
  if (int_currentSampled.length > 0) {                                                    // If at least one individual is sampled 
    sam_currentSample_ilist[int_currentTown_sample] = sam_currentSample_ilist[int_currentTown_sample].concat(int_currentSampled);
    sam_currentSample_hlist[int_currentTown_sample].push(hhid_h);
    x1.style.fill = "#000000";
    x1.style.stroke = "#000000";
  } 
  
  // Update list of sampled towns

 sam_currentSample_tlist = [];
 for (let i = 0; i < sam_currentSample_hlist.length; i++) {
    if (sam_currentSample_hlist[i].length > 0) {
      sam_currentSample_tlist.push(i);
    }
  }
 
  // Calculate new sample sizes 
  
  sam_currentSample_isize[int_currentTown_sample] = sam_currentSample_ilist[int_currentTown_sample].length;
  sam_currentSample_hsize[int_currentTown_sample] = sam_currentSample_hlist[int_currentTown_sample].length;
  
  sam_currentSample_tsize = 0;
  for(const sample of sam_currentSample_hlist) { 
    if (sample.length > 0) {
      sam_currentSample_tsize =  sam_currentSample_tsize + 1;
    }
  }
  
  sam_currentSample_thsize = 0;
  for(const sample of sam_currentSample_hlist) { 
    sam_currentSample_thsize =  sam_currentSample_thsize + sample.length;
  }
 
  sam_currentSample_tisize = 0; 
  for(const sample of sam_currentSample_ilist) { 
    sam_currentSample_tisize =  sam_currentSample_tisize + sample.length;
  }
  
  // Sync samples on R side
  
  Shiny.setInputValue('sam_currentSample_hlist', sam_currentSample_hlist);
  Shiny.setInputValue('sam_currentSample_ilist', sam_currentSample_ilist);
  Shiny.setInputValue('sam_currentSample_tlist', sam_currentSample_tlist);
  
  // Update Interface 
  
  document.getElementById('tssize_sample').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_sample').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_sample').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
  
  document.getElementById('tssize_power').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_power').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_power').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
  
  document.getElementById('tssize_survey').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_survey').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_survey').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
 
  document.getElementById('hssize_town').innerHTML = sam_currentSample_hsize[int_currentTown_sample];  // Sample size in town (households)
  document.getElementById('issize_town').innerHTML = sam_currentSample_isize[int_currentTown_sample];  // Sample size in town (individuals)
  
  document.getElementById("selHous").style.visibility = "hidden";
  
  Shiny.setInputValue('strategy_sample', 0);
  
}  

function deselectHH(hhid) {
  for (const member of int_currentMembers) {
    if (int_currentSampled.includes(member)) {
      document.getElementById(member).style.border = "2px solid red";
    } else {
      document.getElementById(member).style.border = "";
    }
  }
  if (int_currentSampled.length >0) {
    x1.style.fill = "#00FF00";
    x1.style.stroke = "#00FF00";
  }
  
  document.getElementById("selHous").style.visibility = "hidden";
  Shiny.setInputValue('strategy_sample', 0);
}
    
function sampleIND(member) {
  if (document.getElementById(member).style.border == "") {
    document.getElementById(member).style.border = "2px solid red";
    int_newSampled.push(member);
  } else {
    document.getElementById(member).style.border = "";
    for(var i = 0; i < int_newSampled.length; i++) { 
      if (int_newSampled[i] === member) { 
        int_newSampled.splice(i, 1); 
      }
    }
  }  
  
  document.getElementById("strata_sample").innerHTML = "-";
  document.getElementById("clusters_sample").innerHTML = "-";
  document.getElementById("type_sample").innerHTML = "systematic";

  document.getElementById("strata_power").innerHTML = "-";
  document.getElementById("clusters_power").innerHTML = "-";
  document.getElementById("type_power").innerHTML = "systematic";
  
  Shiny.setInputValue('strategy_sample', 0);
}  

function newHSample(type) {
  
  if (type == 0) {
  
    sam_currentSample_hlist[int_currentTown_sample] = [];
    sam_currentSample_ilist[int_currentTown_sample] = [];
    sam_currentSample_hsize[int_currentTown_sample] = 0;
    sam_currentSample_isize[int_currentTown_sample] = 0;
    
    // Update list of sampled towns
   
    sam_currentSample_tlist = [];
    for (let i = 0; i < sam_currentSample_hlist.length; i++) {
      if (sam_currentSample_hlist[i].length > 0) {
        sam_currentSample_tlist.push(i);
      }
    }
      // Calculate new sample sizes 
    
    sam_currentSample_tsize = 0;
    for(const sample of sam_currentSample_hlist) { 
      if (sample.length > 0) {
        sam_currentSample_tsize =  sam_currentSample_tsize + 1;
      }
    }
    
    sam_currentSample_thsize = 0;
    for(const sample of sam_currentSample_hlist) { 
      sam_currentSample_thsize =  sam_currentSample_thsize + sample.length;
    }
   
    sam_currentSample_tisize = 0; 
    for(const sample of sam_currentSample_ilist) { 
      sam_currentSample_tisize =  sam_currentSample_tisize + sample.length;
    }
    
  } else {
    
    sam_currentSample_tlist = [];
    sam_currentSample_hlist = [];
    sam_currentSample_ilist = [];
    sam_currentSample_tsize = 0;
    sam_currentSample_thsize = 0;    
    sam_currentSample_tisize = 0;
    sam_currentSample_hsize = [0];
    sam_currentSample_isize = [0];
    
    for (let i = 0; i < 110; i++) {
      sam_currentSample_hlist.push([]);
      sam_currentSample_ilist.push([]);
      sam_currentSample_hsize.push(0);
      sam_currentSample_isize.push(0);
    }
  }

   // Sync samples on R side
  
  Shiny.setInputValue('sam_currentSample_hlist', sam_currentSample_hlist);
  Shiny.setInputValue('sam_currentSample_ilist', sam_currentSample_ilist);
  Shiny.setInputValue('sam_currentSample_tlist', sam_currentSample_tlist);
  
   // Reset data collection
  
   resetCollection();
  
   // Update Interface 
  
  document.getElementById('hssize_town').innerHTML = sam_currentSample_hsize[int_currentTown_sample];  // Sample size in town (households)
  document.getElementById('issize_town').innerHTML = sam_currentSample_isize[int_currentTown_sample];  // Sample size in town (individuals)
  
  document.getElementById('tssize_sample').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_sample').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_sample').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
  document.getElementById("sratios_sample").innerHTML = "";

  document.getElementById('tssize_power').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_power').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_power').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
  
  document.getElementById('tssize_survey').innerHTML = sam_currentSample_tsize;  // Sample size (towns)
  document.getElementById('hssize_survey').innerHTML = sam_currentSample_thsize;  // Sample size (households)
  document.getElementById('issize_survey').innerHTML = sam_currentSample_tisize;  // Sample size (individuals)
  
  document.getElementById("strata_sample").innerHTML = "-";
  document.getElementById("clusters_sample").innerHTML = "-";
  document.getElementById("type_sample").innerHTML = "-";

  document.getElementById("strata_power").innerHTML = "-";
  document.getElementById("clusters_power").innerHTML = "-";
  document.getElementById("type_power").innerHTML = "-";
  
  document.getElementById("note").style.visibility = "hidden";
  
  Shiny.setInputValue('strategy_sample', 0);
  replaceSvg('panzoom-element_sample',int_currentTown_sample);
  
}

function showSampledHouseholds() {
   sam_currentSample_hlist[int_currentTown_sample].forEach(function(household) {
   $("#" + household).css({"fill":"#000000", "stroke" :'#000000'});
    })
}
 
function showSampledTowns() {
   sam_currentSample_tlist.forEach(function(elem) {
     document.getElementById("iburgSymbol" + elem).setAttribute("r","35");
   });
}

// Sampling Functions (random)

function drawRSample(FORM){
  
  newHSample(1);
  $("#samplespinner").gSpinner();
  $('.sidebar-menu a').addClass('inactiveItem');
  
  let TARGET = [];
 
  for (let i=1; i < 6; i++) {
    if (mon_targetRegions[i-1] === 1) {
      for (let j = 0; j < envir_towns.Region_Code.length; j++) {
        if (envir_towns.Region_Code[j] === i) {
          TARGET.push(envir_towns.Town_Name[j]);
        }
      }
    }
  }
  
  let STYPE = FORM.stratification.value;
  let CTYPE = FORM.clustertype.value;
  
  let clusters = "";
  if (CTYPE == "NONE") {
    clusters = "none";
  } else if (CTYPE == "ONE") {
    clusters = FORM.clust1_1.value.toLowerCase();
  } else {
    clusters = FORM.clust1_2.value.toLowerCase() + ", " + FORM.clust2_2.value.toLowerCase();
  }

  let stratype = "";
  if (CTYPE != "NONE" & STYPE != "NONE") {
    stratype = "cluster, stratified";
  } else if (CTYPE == "NONE" & STYPE != "NONE") {
    stratype = "stratified";
  } else if (CTYPE == "NONE" & STYPE == "NONE") {
    stratype = "simple";
  }
  
     // Reset data collection
  
   resetCollection();
  
    // Updates interface
  
  document.getElementById("strata_sample").innerHTML = STYPE.toLowerCase();
  document.getElementById("clusters_sample").innerHTML = clusters;
  document.getElementById("type_sample").innerHTML = stratype;

  document.getElementById("strata_power").innerHTML = STYPE.toLowerCase();
  document.getElementById("clusters_power").innerHTML = clusters;
  document.getElementById("type_power").innerHTML = stratype;

  let nsex = 1;
  if (FORM.sex.value == "Both") {
    SEX = ["Female", "Male"];
    nsex = 2;
  } else if (FORM.sex.value == "Female") {
    SEX = ["Female"];
  } else {
    SEX = ["Male"];
  };

  let ISS_0 = [FORM.iss_0.value];
  let CLUST1_1 = [FORM.clust1_1.value];
  let NCLUST1_1 = [FORM.nclust1_1.value];
  let PPS1_1 = [FORM.pps1_1.checked];
  let ISS_1 = [FORM.iss_1.value];
  let CLUST1_2 = [FORM.clust1_2.value];
  let NCLUST1_2 = [FORM.nclust1_2.value];
  let PPS1_2 = [FORM.pps1_2.checked];
  let CLUST2_2 = [FORM.clust2_2.value];
  let NCLUST2_2 = [FORM.nclust2_2.value];
  let PPS2_2 = [FORM.pps2_2.checked];  
  let ISS_2 = [FORM.iss_2.value];

  if (CTYPE == "NONE") {
    CLUST1 = "NONE";
    CLUST2 = "NONE";
    NCLUST1 = "NA";
    NCLUST2 = "NA";
    ISSIZE = ISS_0;
    PPS1 = "NA";
    PPS2 = "NA";
  } else if (CTYPE == "ONE") {
    CLUST1 = CLUST1_1;
    CLUST2 = "NONE";
    NCLUST1 = NCLUST1_1;
    NCLUST2 = "NA";
    ISSIZE = ISS_1;
    PPS1 = PPS1_1;
    PPS2 = "NA";
  } else if (CTYPE == "TWO") {  
    CLUST1 = CLUST1_2;
    CLUST2 = CLUST2_2;
    NCLUST1 = NCLUST1_2;
    NCLUST2 = NCLUST2_2;
    ISSIZE = ISS_2;
    PPS1 = PPS1_2;
    PPS2 = PPS2_2;
  } 
  
  let AGEMIN = [FORM.agemin.value];
  let AGEMAX = [FORM.agemax.value];
  
  let STRATEGY = [STYPE].concat([CTYPE],[CLUST1],[NCLUST1],[PPS1],[CLUST2],[NCLUST2],[PPS2],[ISSIZE],[AGEMIN],[AGEMAX],[nsex],SEX,TARGET, Math.random());
  Shiny.setInputValue('targetagemin_strategy',AGEMIN);
  Shiny.setInputValue('targetagemax_strategy',AGEMAX);
  Shiny.setInputValue('targetsex_strategy',SEX);
  
  
  
  Shiny.setInputValue('strategy_strategy',STRATEGY);
}

Shiny.addCustomMessageHandler("handler_update_sample",
    function(data) {
     sam_currentSample_tlist = data[0];
     sam_currentSample_hlist = data[1];
     sam_currentSample_ilist = data[2];
     sam_currentSample_tsize = data[3];
     sam_currentSample_thsize = data[4]; 
     sam_currentSample_tisize = data[5]; 
     sam_currentSample_hsize = data[6]; 
     sam_currentSample_isize = data[7];
     setupcost = data[8];
     collectcost = data[9];   
     totcost = data[10];
     replace = (Number(data[11]) + Number(data[12]) + Number(data[13])) > 0; 
     sratios=  "Target population size: " + Number(data[14]) + ", Maximum sampling ratio: " + data[15];
  
     Shiny.setInputValue('sam_currentSample_hlist', sam_currentSample_hlist);
     Shiny.setInputValue('sam_currentSample_ilist', sam_currentSample_ilist);
     Shiny.setInputValue('sam_currentSample_tlist', sam_currentSample_tlist);
     
     document.getElementById("tssize_survey").innerHTML = sam_currentSample_tsize;
     document.getElementById("hssize_survey").innerHTML = sam_currentSample_thsize;
     document.getElementById("issize_survey").innerHTML = sam_currentSample_tisize;
     
     document.getElementById("tssize_sample").innerHTML = sam_currentSample_tsize;
     document.getElementById("hssize_sample").innerHTML = sam_currentSample_thsize;
     document.getElementById("issize_sample").innerHTML = sam_currentSample_tisize;
     document.getElementById("sratios_sample").innerHTML = sratios;
     
     document.getElementById("tssize_power").innerHTML = sam_currentSample_tsize;
     document.getElementById("hssize_power").innerHTML = sam_currentSample_thsize;
     document.getElementById("issize_power").innerHTML = sam_currentSample_tisize;
     
     document.getElementById("tssize_analyse").innerHTML = sam_currentSample_tsize;
     document.getElementById("hssize_analyse").innerHTML = sam_currentSample_thsize;
     document.getElementById("issize_analyse").innerHTML = sam_currentSample_tisize;
     
     document.getElementById("setupcost_analyse").innerHTML = setupcost;
     document.getElementById("collectcost_analyse").innerHTML = collectcost;
     document.getElementById("totcost_analyse").innerHTML = totcost;
     document.getElementById("unitcost_est_analyse").innerHTML = Math.round(totcost/sam_currentSample_tisize*100)/100;
     
     var map = document.getElementById("panzoom-element_sample");
     map.innerHTML = "<img src='./maps/sample.svg' onload = 'SVGInject(this, options = {makeIdsUnique: false})'/>"; 
     panzoom_sample.pan(-1000, -500);
     panzoom_sample.zoom(0.53, { animate: false });

     setTimeout(function(){showSampledTowns();}, 50);
     setTimeout(function(){
       if (replace == true) {document.getElementById("note").style.visibility = "visible";} else {document.getElementById("note").style.visibility = "hidden";}}, 
     50);
     setTimeout(function(){$("#samplespinner").gSpinner("hide");}, 50);
     setTimeout(function(){showSampledHouseholds();}, 100);
  }                               
);   
