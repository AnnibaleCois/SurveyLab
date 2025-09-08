    // Panzoom Settings  
    
      // World
      
const elem_world = document.getElementById('panzoom-element_world');
const zoomInButton_world = document.getElementById('zoom-in_world');
const zoomOutButton_world = document.getElementById('zoom-out_world');
const resetButton_world = document.getElementById('reset_world');
const panzoom_world = Panzoom(elem_world, {startScale: 0.53, startX:-1000, startY:-500});
const parent_world = elem_world.parentElement;

zoomInButton_world.addEventListener('click', panzoom_world.zoomIn);
zoomOutButton_world.addEventListener('click', panzoom_world.zoomOut);
resetButton_world.addEventListener('click', function(){ 
  if (Shiny.shinyapp.$inputValues["currentTown_explore"] == 0 || Shiny.shinyapp.$inputValues["currentTown_explore"] == null) {
    panzoom_world.pan(-1000, -500);
    panzoom_world.zoom(0.53, { animate: false });
  } else {
    panzoom_world.pan(0,0);
    panzoom_world.zoom(1, { animate: false });
  }
});

parent_world.addEventListener('wheel', panzoom_world.zoomWithWheel);

      // Sample
      
const elem_sample = document.getElementById('panzoom-element_sample');
const zoomInButton_sample = document.getElementById('zoom-in_sample');
const zoomOutButton_sample = document.getElementById('zoom-out_sample');
const resetButton_sample = document.getElementById('reset_sample');
const panzoom_sample = Panzoom(elem_sample, {startScale: 1, startX:0, startY:0});
const parent_sample = elem_sample.parentElement;

zoomInButton_sample.addEventListener('click', panzoom_sample.zoomIn);
zoomOutButton_sample.addEventListener('click', panzoom_sample.zoomOut);
resetButton_sample.addEventListener('click', function(){ 
  if (Shiny.shinyapp.$inputValues["currentTown_sample"] == 0) {
    panzoom_sample.pan(-1000, -500);
    panzoom_sample.zoom(0.53, { animate: false });    
  } else {
    panzoom_sample.pan(0,0);
    panzoom_sample.zoom(1, { animate: false });
  }
});

parent_sample.addEventListener('wheel', panzoom_sample.zoomWithWheel);
                                              