/* User interface scripts - strategy page, v 1.0, 14/09/2024 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

 // Visibility 
 
 document.querySelectorAll('input[name=\'clustertype\']').forEach((radio) => {
  radio.addEventListener('click', (event) => {
    if (event.target.checked) {
      switch (event.target.value) {
        case 'ONE':
          document.getElementById("zerolevels").style.display = "none";
          document.getElementById("onelevel").style.display = "block";
          document.getElementById("twolevels").style.display = "none";
          break;
        case 'TWO':
          document.getElementById("zerolevels").style.display = "none";
          document.getElementById("onelevel").style.display = "none";
          document.getElementById("twolevels").style.display = "block";
          break;
        case 'NONE':
          document.getElementById("zerolevels").style.display = "block";
          document.getElementById("onelevel").style.display = "none";
          document.getElementById("twolevels").style.display = "none";
          break;
        default:
          console.log('Unknown option selected');
      }
    }
  });
});

// Define target population

function ADDtarget(reg){
  var region = document.getElementById("target_" + reg);
  var but = document.getElementById("reg_" + reg);
  if (region.style.display == "none") {
    region.style.display = "block";
    mon_targetRegions[reg-1] = 1;
  } else {
    region.style.display = "none";
    mon_targetRegions[reg-1] = 0;
  };
};  
  
// Reset Strategy

function resetStrategy() {
   // Targets all regions
document.getElementById("reg_1").checked = true;
document.getElementById("reg_2").checked = true;
document.getElementById("reg_3").checked = true;
document.getElementById("reg_4").checked = true;
document.getElementById("reg_5").checked = true;
document.getElementById("target_1").style.display = "block";
document.getElementById("target_2").style.display = "block";
document.getElementById("target_3").style.display = "block";
document.getElementById("target_4").style.display = "block";
document.getElementById("target_5").style.display = "block";
   // Age range
document.getElementById("agemin").value = 15;   // Minimum age 
document.getElementById("agemax").value = 120;  // Maximum age
   // Sex
document.getElementById("sex").checked = true;  // Both sexes included
   // Stratification                       
document.getElementById("stratification").checked = true;  // No stratification
   // No clustering
document.getElementById("iss_0").value = 100;  // Number of individual per stratum when no clustering
   // One level
document.getElementById("clust1_1").checked = true;  // Cluster = Town
document.getElementById("nclust1_1").value = 2;      // Number of clusters per stratum
document.getElementById("pps1_1").checked = true;    // Probability of cluster selection proportional to size
document.getElementById("iss_1").value = 20;         // Number of individuals per cluster
   // Two levels
document.getElementById("clust1_2").checked = true;  // Cluster level 1 = Town  
document.getElementById("nclust1_2").value = 2;      // Number of clusters per stratum
document.getElementById("pps1_2").checked = true;    // Probability of level 1 cluster selection proportional to size
document.getElementById("clust2_2").checked = true;  // Cluster level 2 = Household  
document.getElementById("nclust2_2").value = 20;     // Number of clusters per level 1 cluster
document.getElementById("pps2_2").checked = true;    // Probability of level 2 cluster selection proportional to size
document.getElementById("iss_2").value = 1;          // Number of individuals per level 2 cluster

document.getElementById("clustertype").click();      // Clstering type = no clustering (simple random sampling within each stratum)
}




 