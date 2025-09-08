/* User interface scripts - power page, v 3.0, 01/08/2024 */
/* Annibale Cois (acois@sun.ac.za)*/    


// Power calculations

function calcPower(FORM1, FORM2){
  
  document.getElementById("powerrr").style.opacity = 0.4;
   $("#powerspinner").gSpinner();
  
  let OUTCOME = FORM1.eoutcome.value;
  let RRMIN = FORM1.eoutcome_min.value;
  let RRMAX = 100;
  
  let EXPPROP = FORM1.eoutcome_eprop.value;
  let EXPSD = FORM1.eoutcome_esd.value;
  let EXPDEFF = FORM1.eoutcome_edeff.value;
  let EXPAUTO = FORM1.eoutcome_auto.checked;
  
  let STYPE = FORM2.stratification.value;
  let CTYPE = FORM2.clustertype.value;
  
  let nsex = 1;
  if (FORM2.sex.value == "Both") {
    SEX = ["Female", "Male"];
    nsex = 2;
  } else if (FORM.sex.value == "Female") {
    SEX = ["Female"];
  } else {
    SEX = ["Male"];
  };

  let AGEMIN = [FORM2.agemin.value];
  let AGEMAX = [FORM2.agemax.value];
  
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
  
  let ISS_0 = [FORM2.iss_0.value];
  let CLUST1_1 = [FORM2.clust1_1.value];
  let NCLUST1_1 = [FORM2.nclust1_1.value];
  let PPS1_1 = [FORM2.pps1_1.checked];
  let ISS_1 = [FORM2.iss_1.value];
  let CLUST1_2 = [FORM2.clust1_2.value];
  let NCLUST1_2 = [FORM2.nclust1_2.value];
  let PPS1_2 = [FORM2.pps1_2.checked];
  let CLUST2_2 = [FORM2.clust2_2.value];
  let NCLUST2_2 = [FORM2.nclust2_2.value];
  let PPS2_2 = [FORM2.pps2_2.checked];  
  let ISS_2 = [FORM2.iss_2.value];

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
    PPS2 = PPS1_2;
  } 
  
  let POWERDATA = [STYPE].concat([CTYPE],[CLUST1],[NCLUST1],[PPS1],[CLUST2],[NCLUST2],[PPS2],[ISSIZE],[AGEMIN],[AGEMAX],[nsex],SEX,TARGET, 
  OUTCOME,EXPPROP,EXPSD,EXPDEFF,EXPAUTO,RRMIN,RRMAX, Math.random());
  Shiny.setInputValue('power_calc',POWERDATA);

}

Shiny.addCustomMessageHandler("handler_power_calculations",
  function(data) {
    let deff = data[0];
    let prec = data[1]; 
    let vartype = data[2];
    let expsd = data[3];
    let expprop = data[4];    
    let worst = data[5];  

    if (vartype == "n") {
      document.getElementById("prec_power").innerHTML = "±" + Math.round(prec.TOTAL[prec.TOTAL.length - 1]*10)/10;
      document.getElementById("sprec_power").innerHTML = "±" +  worst;
      document.getElementById("popvar_power").innerHTML = Math.round(expsd*10)/10;
      document.getElementById("outtype_power").innerHTML = "Numeric"
    } else {
      document.getElementById("prec_power").innerHTML = "±" + Math.round(prec.TOTAL[prec.TOTAL.length - 1]*10)/10 + "%";
      document.getElementById("sprec_power").innerHTML = "±" + worst + "%";
      document.getElementById("popvar_power").innerHTML = Math.round(expprop*10)/10 + "%";
      document.getElementById("outtype_power").innerHTML = "Categorical"
    }
    document.getElementById("deff_power").innerHTML = deff;
    document.getElementById("powerrr").style.background = "none";
    
    // Show cost
    
    let setupcost = document.getElementById("setupcost_analyse").innerHTML;
    let collectcost = document.getElementById("collectcost_analyse").innerHTML;
    let totcost = document.getElementById("totcost_analyse").innerHTML;
    let unitcost = Math.round(totcost/sam_currentSample_tisize*10)/10;

    document.getElementById("setupcost_power").innerHTML = setupcost;
    document.getElementById("collectcost_power").innerHTML = collectcost;
    document.getElementById("totcost_power").innerHTML = totcost;
    document.getElementById("unitcost_power").innerHTML = unitcost;
    
    document.getElementById("powerrr").style.opacity = 1;
    $("#powerspinner").gSpinner("hide");
    
    // Graph 
    
    new Chart("powerrr", {
      type: "line",
      data: {
        labels: prec.RR,
        datasets: [{
          label:"Precision of estimates",
          data: prec.TOTAL,
          fill: false,
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      },
      options: {
        scales: {
          xAxes: [{ticks: {reverse: true}}],
          yAxes: [{scaleLabel: {display: true, labelString: "Precision [±]"}}]
        }
      }
  })  
});   

// Interface (recalculate power when the inputs changes)

function recalcPower() {
  document.getElementById('eoutcome_eprop').disabled = autocalc.checked;
  document.getElementById('eoutcome_esd').disabled = autocalc.checked;
  document.getElementById('eoutcome_edeff').disabled = autocalc.checked;
  
  document.getElementById("prec_power").innerHTML = "---";
  document.getElementById("sprec_power").innerHTML = "---";
  document.getElementById("popvar_power").innerHTML = "---";

  document.getElementById("deff_power").innerHTML = "---";
  document.getElementById("powerrr").style.background = "none";
  
  document.getElementById("setupcost_power").innerHTML = "---";
  document.getElementById("collectcost_power").innerHTML = "---";
  document.getElementById("totcost_power").innerHTML = "---";
  document.getElementById("unitcost_power").innerHTML = "---";
  
  document.getElementById("powerrr").style.opacity = 0.4;
  calcPower(powerform,strategyform);
}

const autocalc = document.getElementById('eoutcome_auto');
autocalc.addEventListener('change', recalcPower);
document.getElementById('eoutcome')?.addEventListener('change', recalcPower);
document.getElementById('eoutcome_min')?.addEventListener('change', recalcPower);
document.getElementById('eoutcome_eprop')?.addEventListener('change', recalcPower);
document.getElementById('eoutcome_esd')?.addEventListener('change', recalcPower);
document.getElementById('eoutcome_edeff')?.addEventListener('change', recalcPower);
