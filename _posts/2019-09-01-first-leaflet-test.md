---
layout: post
title: First Leaflet Test
linktormd: true
leafletmap: true
always_allow_html: yes
output: github_document
date: 2019-09-01
---

This is my first blog post featuring a leaflet map. 
I've followed the step-by-step guide provided in 
this [blog post](https://dieghernan.github.io/201905_Leaflet_R_Jekyll/) and apparently it works. 

To say that I'm happy would be an understatement. 
Now I'm able to write blog post with maps embedded 
in it. I'm going to look up how to "beautify" 
this website though; perhaps I'm going to find 
some custom themes. God knows how bad I am with CSS.

Anyway, here's the birthplace of R language.

``` r
library(leaflet)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, 
  popup="The birthplace of R")
m  # Print the map
```

<!--html_preserve-->

<div id="htmlwidget-34e3a38a09ff3a910f03" class="leaflet html-widget" style="width:100%;height:480px;">

</div>

<script type="application/json" data-for="htmlwidget-34e3a38a09ff3a910f03">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-36.852,174.768,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"The birthplace of R",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-36.852,-36.852],"lng":[174.768,174.768]}},"evals":[],"jsHooks":[]}</script>

<!--/html_preserve-->
