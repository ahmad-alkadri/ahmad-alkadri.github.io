---
layout: post
title: Weekend R Project - Flixbus' Stops in Switzerland
linktormd: true
leafletmap: true
always_allow_html: yes
output: github_document
tags: [personal, blog, leaflet, map, spatial, R]
date: 2019-09-07
---

Having been avid users of Flixbus for three years now, I and my wife
know very well the importance of knowing *where the Flixbus stop* in our
destination is.

And not only for Flixbus, but also for other modes of mass
transportations, such as train. Traditionally, before departing for
traveling, we always gathered all the addresses of Flixbus stops that we
would go to. And we always saved them *offline*, for the rare cases
where our smartphones are dead and we’re without any charging stations
nearby, so that in those situations we would always still be able to ask
people around us on directions.

So how do we did it, usually? Well, normally we visited the Flixbus
website and looked up the addresses for each cities that we’re going to
visit and copied-pasted them into a Word document. However, this
week-end I’ve got an idea to try to do this little project, where we
would scrape these data online using R and `rvest` package, and then
visualizing their addresses in map using OpenStreetMap, accessible
through `tmaptools` package. Admittedly, I’ve never used OpenStreetMap
for geocoding before, so I think it could also a good case study to
check its capability.

So, in short:

  - in this project I used the web-scraping package of R, `rvest`, to
    obtain the addresses of Flixbus’ stops in *Switzerland* (because
    we’ve just finished our summer road trip in that country),

  - afterwards, I used `tmaptools` package to geocode those address
    using OSM and obtaining their coordinates, and

  - finally, using those coordinates, I mark their locations on an
    interactive map using `leaflet` package.

# Step 1: Obtaining the Xpaths from the Flixbus Website

Firstly I’d like to say one thing about Flixbus website: I love it. It
contains pretty much every information that I need about routes, bus
stops, schedules, etc. It is also very consistent, with each country
page containing the list of cities that they serve, and each city page
containing the address(es) of the bus stops in that city.

Scraping the information from their website thus proven very simple. The
first thing I did was visiting their web page for [Switzerland
destinations](https://global.flixbus.com/bus/switzerland):

![](https://github.com/ahmad-alkadri/ahmad-alkadri.github.io/blob/master/_posts/2019-09-07-wp-scraping-flixbus-switzerland_files/2019-09-07-wp-scraping-flixbus-switzerland_webpage_front.png?raw=true)

Scrolling down a little bit, you’ll see the list of cities served by the
FlixBus. Using a Chrome extension called [Selector
Gadget](https://chrome.google.com/webstore/search/selector%20gadget), I
selected the cities and obtained their xpath:

![](https://github.com/ahmad-alkadri/ahmad-alkadri.github.io/blob/master/_posts/2019-09-07-wp-scraping-flixbus-switzerland_files/2019-09-07-wp-scraping-flixbus-switzerland_webpage_xpaths.png?raw=true)

Afterwards, I navigated to one of the cities listed and copied the xpath
of their bus stop address:

![](https://github.com/ahmad-alkadri/ahmad-alkadri.github.io/blob/master/_posts/2019-09-07-wp-scraping-flixbus-switzerland_files/2019-09-07-wp-scraping-flixbus-switzerland_webpage_cities.png?raw=true)

And that’s Step 1 finished.

# Step 2: Scraping the Website

Before doing the heavy work, I’d like to re-state some rules that I have
regarding web scraping:

  - do not encumber their server too much; put adequate *intervals* in
    between requests,

  - the script that need to be reproducible,

  - the data need to be readable.

Among those things, I think the first one if very important, especially
if we’re going to scrape lots of informations from different pages just
like what I did here. Anyway, first thing first, let’s load the
necessary libraries:

``` r
library(rvest)         # For web scraping
library(leaflet)       # For visualizing the map
library(dplyr)         # For the syntax
library(data.table)    # For data wrangling
library(tmaptools)     # For the geocoding
library(kableExtra)    # For visualizing tables in HTML
```

Now, let’s start the scraping:

## Scraping Part 1: List of Destinations

Firstly, we need to get a list of destinations or cities served by the
Flixbus in Switzerland and their respective pages with the bus stop
addresses inside. So, we do this by this script:

``` r
#Reading the website
webpage <- read_html("https://global.flixbus.com/bus/switzerland")

#Obtaining the destinations
## Destination names
dest.names <- webpage %>% 
  html_nodes(xpath = "//div[@class='hubpage-col col-md-3 col-sm-3']") %>% 
  html_nodes("li") %>% 
  html_text(trim=TRUE)

## Destination links
dest.links <- webpage %>% 
  html_nodes(xpath = "//div[@class='hubpage-col col-md-3 col-sm-3']") %>% 
  html_nodes("li") %>% 
  html_nodes("a") %>% 
  html_attr("href")
```

To make those informations more readable, we put them in a dataframe and
visualized them using `kable()` function as follows:

``` r
#Making a dataframe containing the names and links of the destinations
dest.table <- data.frame(dest.names, dest.links) 
names(dest.table) <- c("Cities","Pages")

#Preview the table
kable(dest.table, 
      caption = "List of Switzerland Cities connected by Flixbus") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  scroll_box(height = "400px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; ">

<table class="table table-striped table-hover" style="margin-left: auto; margin-right: auto;">

<caption>

List of Switzerland Cities connected by
Flixbus

</caption>

<thead>

<tr>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

Cities

</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

Pages

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Airolo

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/airolo>

</td>

</tr>

<tr>

<td style="text-align:left;">

Baden

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/baden>

</td>

</tr>

<tr>

<td style="text-align:left;">

Basel

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/basel-weil-am-rhein>

</td>

</tr>

<tr>

<td style="text-align:left;">

Basel EuroAirport (CH)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/basel-euroairport-ch>

</td>

</tr>

<tr>

<td style="text-align:left;">

Bellinzona

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bellinzona>

</td>

</tr>

<tr>

<td style="text-align:left;">

Bern

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bern>

</td>

</tr>

<tr>

<td style="text-align:left;">

Biasca

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/biasca>

</td>

</tr>

<tr>

<td style="text-align:left;">

Biel

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/biel>

</td>

</tr>

<tr>

<td style="text-align:left;">

Bulle

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bulle>

</td>

</tr>

<tr>

<td style="text-align:left;">

Chur

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/chur>

</td>

</tr>

<tr>

<td style="text-align:left;">

Flüelen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fluelen>

</td>

</tr>

<tr>

<td style="text-align:left;">

Fribourg (Suisse)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fribourg>

</td>

</tr>

<tr>

<td style="text-align:left;">

Füllinsdorf

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fullinsdorf>

</td>

</tr>

<tr>

<td style="text-align:left;">

Geneva

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/geneva>

</td>

</tr>

<tr>

<td style="text-align:left;">

Geneva Airport

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/geneva-airport>

</td>

</tr>

<tr>

<td style="text-align:left;">

Grindelwald

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/grindelwald>

</td>

</tr>

<tr>

<td style="text-align:left;">

Göschenen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/goschenen>

</td>

</tr>

<tr>

<td style="text-align:left;">

Horgen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/horgen>

</td>

</tr>

<tr>

<td style="text-align:left;">

Interlaken

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/interlaken>

</td>

</tr>

<tr>

<td style="text-align:left;">

Landquart

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/landquart>

</td>

</tr>

<tr>

<td style="text-align:left;">

Lausanne

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lausanne>

</td>

</tr>

<tr>

<td style="text-align:left;">

Lugano

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lugano>

</td>

</tr>

<tr>

<td style="text-align:left;">

Luzern

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lucerne>

</td>

</tr>

<tr>

<td style="text-align:left;">

Martigny

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/martigny>

</td>

</tr>

<tr>

<td style="text-align:left;">

Mendrisio

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/mendrisio>

</td>

</tr>

<tr>

<td style="text-align:left;">

Montreux

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/montreux>

</td>

</tr>

<tr>

<td style="text-align:left;">

Neuchâtel (Switzerland)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/neuchatel-switzerland>

</td>

</tr>

<tr>

<td style="text-align:left;">

Nyon

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/nyon>

</td>

</tr>

<tr>

<td style="text-align:left;">

Olten

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/olten>

</td>

</tr>

<tr>

<td style="text-align:left;">

Schaffhausen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/schaffhausen>

</td>

</tr>

<tr>

<td style="text-align:left;">

Sion

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/sion>

</td>

</tr>

<tr>

<td style="text-align:left;">

Solothurn

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/solothurn>

</td>

</tr>

<tr>

<td style="text-align:left;">

Splügen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/splugen>

</td>

</tr>

<tr>

<td style="text-align:left;">

St. Gallen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/st-gallen>

</td>

</tr>

<tr>

<td style="text-align:left;">

Stans

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/stans>

</td>

</tr>

<tr>

<td style="text-align:left;">

Sursee

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/sursee>

</td>

</tr>

<tr>

<td style="text-align:left;">

Thun

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/thun>

</td>

</tr>

<tr>

<td style="text-align:left;">

Vevey

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/vevey>

</td>

</tr>

<tr>

<td style="text-align:left;">

Winterthur

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/winterthur>

</td>

</tr>

<tr>

<td style="text-align:left;">

Yverdon les Bains

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/yverdon-les-bains>

</td>

</tr>

<tr>

<td style="text-align:left;">

Zurich

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/zurich>

</td>

</tr>

<tr>

<td style="text-align:left;">

Zurich Airport

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/zurich-airport>

</td>

</tr>

</tbody>

</table>

</div>

And that’s Scraping Part 1 finished.

## Scraping Part 2: Addresses of the Bus Stops

Now that we’ve had all the names and links for each destinations, the
next thing we had to do is obtaining the bus stops’ addresses.

Again, I’d like to tell you again that the FlixBus website is honestly,
in my humble opinion, one of the most well-made, well-crafted, and
well-written bus websites that I’ve ever found. Every city has its own
page. Each of them has the same format and structure. The consistency is
very good. So without further ado, here is the script that I use to
scrape the addresses from their pages. Notice I put ‘sleep time’ in
between scraping each pages so that I won’t encumber the server too
much:

``` r
#Make empty list
dat.cities <- list()

#Scrape from each city
for (city in dest.table$Cities) {
  
  dest.tmp <- dest.table[dest.table$Cities==city,]
  
  #Obtain the web of a city
  wp.tmp <- read_html(as.character(dest.tmp$Pages))
  
  lst.tmp <- wp.tmp %>% 
    html_nodes("address.bus-stop-overview__stop__orig")
  
  for (i in 1:length(lst.tmp)) {
  
    ads.tmp <- lst.tmp[i] %>% 
      html_nodes("span") %>% 
      html_text(trim=TRUE) %>% 
      gsub('\"','', .)
  
    dat.tmp <- data.frame(city,paste(ads.tmp,collapse = ", "))
  
    names(dat.tmp) <- c("Cities","Address")
  
    if(i == 1){
    
      dat.cty <- dat.tmp
  
      } else {
    
        dat.cty <- rbind(dat.cty,dat.tmp)
  
        }

  }
  
  dat.cities[[city]] <- dat.cty
  
  Sys.sleep(3) #Each time, we give the website a "rest time" for three seconds

}
```

And that’s it, we have all the addresses of all the bus stops. To make
it easier to read, let’s convert the list of addresses above into a data
frame:

``` r
#Convert the list into a dataframe
dest.addresses <- rbindlist(dat.cities)
```

Now, to make it *even easier* to read, let’s merge the two data frames
(`dest.addresses` and `dest.table`) into ***one*** data frame based on
the column `Cities`.

``` r
# Merging
dest.results <- merge(dest.table, dest.addresses, by = "Cities")

# Preview the results
kable(dest.results, 
      caption = "List of cities and their bus stops") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  scroll_box(height = "400px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; ">

<table class="table table-striped table-hover" style="margin-left: auto; margin-right: auto;">

<caption>

List of cities and their bus
stops

</caption>

<thead>

<tr>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

Cities

</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

Pages

</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

Address

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Airolo

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/airolo>

</td>

<td style="text-align:left;">

Via Fontana, 6780 Airolo, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Baden

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/baden>

</td>

<td style="text-align:left;">

Brown Boveri Str. 16-20, 5400 Baden, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Basel

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/basel-weil-am-rhein>

</td>

<td style="text-align:left;">

Meret Oppenheim-Strasse, 4053 Basel, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Basel EuroAirport (CH)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/basel-euroairport-ch>

</td>

<td style="text-align:left;">

Flughafen Basel-Mulhouse, 4030 Basel EuroAirport (CH), Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Bellinzona

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bellinzona>

</td>

<td style="text-align:left;">

Via Stazione, 6532 Bellinzona, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Bern

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bern>

</td>

<td style="text-align:left;">

Studerstrasse, 3012 Bern, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Biasca

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/biasca>

</td>

<td style="text-align:left;">

Via Generale Guisan 2, 6710 Biasca, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Biel

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/biel>

</td>

<td style="text-align:left;">

Stadien/Stades, 2504 Biel, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Bulle

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/bulle>

</td>

<td style="text-align:left;">

Rue de Vuippens 49, 1630 Bulle, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Chur

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/chur>

</td>

<td style="text-align:left;">

Gürtelstrasse 14, 7000 Chur, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Flüelen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fluelen>

</td>

<td style="text-align:left;">

Bahnhofstrasse, 6454 Flüelen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Fribourg (Suisse)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fribourg>

</td>

<td style="text-align:left;">

Chemin Saint-Léonard, 1700 Fribourg (Suisse), Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Fribourg (Suisse)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fribourg>

</td>

<td style="text-align:left;">

Rue Louis-d’Affry 2, 1700 Fribourg (Suisse), Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Füllinsdorf

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/fullinsdorf>

</td>

<td style="text-align:left;">

Rheinstrasse 2, 4414 Füllinsdorf, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Geneva

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/geneva>

</td>

<td style="text-align:left;">

Place Dorcière, 1201 Geneva, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Geneva

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/geneva>

</td>

<td style="text-align:left;">

Place Martin Luther King, 74100 Geneva, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Geneva Airport

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/geneva-airport>

</td>

<td style="text-align:left;">

Route de l’aéroport, 1215 Geneva Airport, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Göschenen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/goschenen>

</td>

<td style="text-align:left;">

Bahnhofplatz, 6487 Göschenen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Grindelwald

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/grindelwald>

</td>

<td style="text-align:left;">

Endweg, 3818 Grindelwald, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Horgen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/horgen>

</td>

<td style="text-align:left;">

Dorfgasse, 8810 Horgen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Interlaken

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/interlaken>

</td>

<td style="text-align:left;">

Rugenparkstrasse, 3800 Interlaken, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Landquart

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/landquart>

</td>

<td style="text-align:left;">

Tardisstrasse 20, 7205 Landquart, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Lausanne

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lausanne>

</td>

<td style="text-align:left;">

Route des Plaines-du-Loup, 1018 Lausanne, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Lugano

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lugano>

</td>

<td style="text-align:left;">

Via Giacomo E Filippo Ciani, 6900 Lugano, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Luzern

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/lucerne>

</td>

<td style="text-align:left;">

Inseliquai, 6005 Luzern, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Martigny

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/martigny>

</td>

<td style="text-align:left;">

Rue d’Aoste, 1920 Martigny, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Mendrisio

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/mendrisio>

</td>

<td style="text-align:left;">

Via Laveggio, 6850 Mendrisio, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Montreux

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/montreux>

</td>

<td style="text-align:left;">

Chailly P+R, 1816 Montreux, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Neuchâtel (Switzerland)

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/neuchatel-switzerland>

</td>

<td style="text-align:left;">

Rue des Beaux-Arts 2, 2000 Neuchâtel (Switzerland), Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Nyon

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/nyon>

</td>

<td style="text-align:left;">

Impasse de Champ-Colin 12, 1260 Nyon, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Olten

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/olten>

</td>

<td style="text-align:left;">

Gösgerstrasse, 4600 Olten, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Schaffhausen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/schaffhausen>

</td>

<td style="text-align:left;">

Spitalstrasse 5, Landhaus, 8200 Schaffhausen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Sion

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/sion>

</td>

<td style="text-align:left;">

Rue de la Traversiere 2, 1950 Sion, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Solothurn

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/solothurn>

</td>

<td style="text-align:left;">

Zuchwilerstrasse 33, 4500 Solothurn, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Splügen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/splugen>

</td>

<td style="text-align:left;">

Italienische Strasse 44, 7435 Splügen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

St. Gallen

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/st-gallen>

</td>

<td style="text-align:left;">

Lagerstrasse 10, 9000 St. Gallen, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Stans

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/stans>

</td>

<td style="text-align:left;">

Bluemattstrasse 1, 6370 Stans, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Sursee

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/sursee>

</td>

<td style="text-align:left;">

Surentalstrasse, 6210 Sursee, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Thun

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/thun>

</td>

<td style="text-align:left;">

Talackerstrasse 62, 3604 Thun, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Vevey

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/vevey>

</td>

<td style="text-align:left;">

Avenue Reller, 1800 Vevey, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Winterthur

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/winterthur>

</td>

<td style="text-align:left;">

Lagerhausstrasse 18, 8400 Winterthur, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Yverdon les Bains

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/yverdon-les-bains>

</td>

<td style="text-align:left;">

Avenue de la Gare, 1400 Yverdon les Bains, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Zurich

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/zurich>

</td>

<td style="text-align:left;">

Ausstellungsstrasse 5, 8005 Zurich, Switzerland

</td>

</tr>

<tr>

<td style="text-align:left;">

Zurich Airport

</td>

<td style="text-align:left;">

<https://global.flixbus.com/bus/zurich-airport>

</td>

<td style="text-align:left;">

Flughafenstrasse (Bus station), 8302 Zurich Airport, Switzerland

</td>

</tr>

</tbody>

</table>

</div>

Finally, let’s just save these informations into a CSV file so we can
inspect them, and even print them, so we can consult it even without
internet connection:

``` r
write.csv(dest.results, 
          "switzerland_destinations_addresses.csv")
```

And that’s the scraping parts, finished\!

# Step 3: Geocoding

Now that we have obtained their addresses, it’s time to find their
coordinates. To do this, we used `tmaptools`’s `geocode_OSM` function.

Firstly, let’s make three additional columns in the `dest.results` data
frame for the longitudinal and latitude of each street addresses *and*
also for a note to let us know if the geocoding is successful or not:

``` r
dest.results$Lon <- NA
dest.results$Lat <- NA
dest.results$Note <- NA
```

Then, let’s loop over each rows of the `dest.results` data frame to get
the coordinates of each addresses *and* put them directly into the `Lon`
and `Lat` column:

``` r
for (i in 1:nrow(dest.results)) {
  
  tryCatch({ # We put this here so that, if OSM failed in finding the 
             # coordinates, it will not stop the loop
    
    res_geo <- geocode_OSM(as.character(dest.results$Address[i]),
            as.data.frame = TRUE)
    
    dest.results$Lon[i] <- res_geo$lon
    
    dest.results$Lat[i] <- res_geo$lat
    
  }, warning=function(w){Sys.sleep(0)})
  
  Sys.sleep(3) #Each time, we give the OSM a "rest time" of three seconds
  
}
```

We found that, apparently, there are some addresses that we couldn’t
find using OSM. That’s unfortunate, but that also shows us the
capability of OSM, which is one of the objectives that we wanted from
this project.

So let’s put a message on those addresses that we couldn’t find so that
it is clear which one has the exact coordinates and which one doesn’t.

``` r
for (i in 1:nrow(dest.results)) {
  
  if(is.na(dest.results$Lon[i]) | is.na(dest.results$Lat[i])){
    dest.results$Note[i] <- "Coordinates not found on OSM"
  }else{
    dest.results$Note[i] <- "Coordinates found"
  }
  
}
```

And finally, let’s calculate the percentage of places found by OSM and
the percentage of those who wasn’t
found:

``` r
percent_found <- nrow(dest.results[dest.results$Note == "Coordinates found",])/nrow(dest.results)*100

percent_notfound <- nrow(dest.results[dest.results$Note == "Coordinates not found on OSM",])/nrow(dest.results)*100

pie(c(percent_found,percent_notfound), 
    labels = c(paste("Found (", percent_found, "%)", sep = ""),
               paste("Not found (", percent_notfound, "%)", sep = "")), 
    main="Percentage of Bus Stops Found and Not Found by OSM")
```

![](https://github.com/ahmad-alkadri/ahmad-alkadri.github.io/blob/master/_posts/2019-09-07-wp-scraping-flixbus-switzerland_files/figure-gfm/successrateOSM-1.png?raw=true)<!-- -->

# Step 4: Visualizing on Map

We now have the addresses and the coordinates for, well, *most* of the
bus stop. Now, let’s put them on the map using `leaflet` package.

To do that, firstly we need to frame them in a larger map, which in this
case, is the map of Switzerland:

``` r
geoswitzerland <- geocode_OSM("Switzerland",
                         as.data.frame = TRUE)

mapres <- leaflet(width = "100%")

mapres <- addTiles(mapres)

mapres <- fitBounds(mapres, lng1 = geoswitzerland$lon_min, lng2 = geoswitzerland$lon_max,
            lat1 = geoswitzerland$lat_min, lat2 = geoswitzerland$lat_max)
```

Afterwards, we put the locations using markers on this map by looping
over each found coordinates:

``` r
for (i in 1:nrow(dest.results)) {
  tryCatch({
    
    
  }, warning=function(w){"Coordinates not found on OSM"})
  if(dest.results$Note[i]=="Coordinates found"){
    
    mapres <- addMarkers(mapres,
                       lng = as.numeric(dest.results$Lon[i]),
                       lat = as.numeric(dest.results$Lat[i]),
                       popup = as.character(dest.results$Address[i]))
      
  } else {
    
    Sys.sleep(0)
    
  }
  
  
}

# Show the map
mapres
```

<!--html_preserve-->

<div id="htmlwidget-c7ff61834f9c1030ba81" class="leaflet html-widget" style="width:100%;height:480px;">

</div>

<script type="application/json" data-for="htmlwidget-c7ff61834f9c1030ba81">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[46.5247257,8.6018763,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Via Fontana, 6780 Airolo, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.4798194,8.3050274,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Brown Boveri Str. 16-20, 5400 Baden, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.5458731,7.5894754,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Meret Oppenheim-Strasse, 4053 Basel, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.195663,9.0290092,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Via Stazione, 6532 Bellinzona, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.9628848,7.4326294,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Studerstrasse, 3012 Bern, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.3592401,8.9692931,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Via Generale Guisan 2, 6710 Biasca, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.1563636,7.2815253,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Stadien/Stades, 2504 Biel, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.6267454,7.0609729,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Rue de Vuippens 49, 1630 Bulle, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.8529854,9.5266889,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Gürtelstrasse 14, 7000 Chur, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.8961093,8.6224606,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Bahnhofstrasse, 6454 Flüelen, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.5192476,7.7183287,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Rheinstrasse 2, 4414 Füllinsdorf, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.2084236,6.1465941,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Place Dorcière, 1201 Geneva, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.6231688,8.0349541,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Endweg, 3818 Grindelwald, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.2606684,8.5992007,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Dorfgasse, 8810 Horgen, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.6810628,7.851769,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Rugenparkstrasse, 3800 Interlaken, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.9613726,9.5537225,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Tardisstrasse 20, 7205 Landquart, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.5336232,6.6262459,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Route des Plaines-du-Loup, 1018 Lausanne, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.015894,8.9614531,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Via Giacomo E Filippo Ciani, 6900 Lugano, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.0487612,8.3141415,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Inseliquai, 6005 Luzern, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.1046024,7.0802747,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Rue d'Aoste, 1920 Martigny, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[45.8837099,8.9800467,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Via Laveggio, 6850 Mendrisio, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.3839602,6.22121903713819,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Impasse de Champ-Colin 12, 1260 Nyon, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.3639672,7.9126423,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Gösgerstrasse, 4600 Olten, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.2034252,7.5427226,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Zuchwilerstrasse 33, 4500 Solothurn, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.5556467,9.3332148,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Italienische Strasse 44, 7435 Splügen, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.4223591,9.3666605,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Lagerstrasse 10, 9000 St. Gallen, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.9612994,8.36368965,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Bluemattstrasse 1, 6370 Stans, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.1797645,8.1105133,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Surentalstrasse, 6210 Sursee, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.7444501,7.6138807,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Talackerstrasse 62, 3604 Thun, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.4676699,6.8370102,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Avenue Reller, 1800 Vevey, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.4977472,8.7234524,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Lagerhausstrasse 18, 8400 Winterthur, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[46.7818492,6.6386789,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Avenue de la Gare, 1400 Yverdon les Bains, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addMarkers","args":[47.38088325,8.53739033168773,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"Ausstellungsstrasse 5, 8005 Zurich, Switzerland",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"fitBounds":[45.817995,5.9559113,47.8084648,10.4922941,[]],"limits":{"lat":[45.8837099,47.5458731],"lng":[6.1465941,9.5537225]}},"evals":[],"jsHooks":[]}</script>

<!--/html_preserve-->

And that’s the visualization, finished.

# Final Thoughts

So those are the results that I have obtained through these web-scraping
scripts that I made. We’ve got ourselves the list of the cities
connected by the Flixbus network in Switzerland and, what’s more, we
know the addresses of Flixbus stops in those cities. We’ve succeeded in
saving them and exporting them into a text file, which is very good, and
if you’re a frequent traveler (or backpacker, like I used to be), I
think we can always appreciate having those addresses handly, offline,
and ready to be printed.

Then came the part where we tried to search those addresses using OSM,
wherein we found out that not all of those addresses could be found by
OSM. Sure, you can use Google Maps instead of OSM for geocoding, but the
reason why I chose to use OSM here is because of their openness and
freeness. Unlike Google Maps, which now limits the number of requests
(of course, any internet map service provider has the right to do that),
and who asks us to create a “billing” account to use their API, OSM
allows people like me–who really likes having a reproducible,
easy-to-use right of the bat scripts (really, you can download this R
markdown file and run it by yourself through your Rstudio and I am quite
certain that you’ll have the same results)–to do geocoding openly and
freely.

If you’re someone like me, who is a proponent of open access to data, I
think you’re going to agree that having a free, accurate geographic
dataset is more important than ever now, especially with the rise of
self-driving cars and services. And if you’re still unconvinced about
the importance of OSM, I’d like to suggest to you to read
[this](https://blog.emacsen.net/blog/2014/01/04/why-the-world-needs-openstreetmap/)
blog post and
[this](https://www.linuxjournal.com/content/openstreetmap-should-be-priority-open-source-community)
article. *Those things being said*, we can’t deny that OSM itself still
needs improvement, [especially in
geocoding](https://blog.emacsen.net/blog/2018/02/16/osm-is-in-trouble/).
That doesn’t mean we should stop using it, it just means that OSM is
still developing and that we can contribute to that.

Finally, I’d just like to point out that the FlixBus website themselves
actually contain the coordinates of **all the addresses** of their
FlixBus stops. You can check it out. But the objective of this project
is, again, is not to really obtain all those coordinates, it is to see
the capability of OSM for geocoding of these addresses. And in my
opinion, OSM is already very good for that, although they could improve,
certainly. And at the end, the most impotant thing is, perhaps: we have
obtained the list of all FlixBus stops addresses in Switzerland, and it
should be very handy to have, especially in conditions where we are
traveling without a consistent internet access.

# Closing

Any questions? Thoughts? Perhaps you’ve found some errors in my codes?
Feel free to hit me at my
[LinkedIn](https://www.linkedin.com/in/alkadri) or
[email](mailto:ahmad.alkadri@outlook.com). God knows I still need to
learn a lot. Always love to discuss\!
