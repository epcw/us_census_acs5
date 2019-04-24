#!/bin/bash

##Queries the US Census's 5-year American Community survey API for info.  Replace query array with desired variables, and add the appropriate q_human translations at the bottom.  You will need to apply for a (free) US Census API key and replace the key below with yours

#usage: ./census-acs5-query.sh

#backup old files
mkdir -p archive
files="*.txt"
for f in $files
do
mv $f archive/$f
done

#set dataset & year
dataset="acs5"
year="2016"

query=( "Variable1 - i.e. B01001_001E" "variable2" "variable3" ) #define queries (list here - https://api.census.gov/data/2016/acs/acs5/variables.html)
#query=( "B01002_001E" ) #single query commented out for testing purposes

for q in  "${query[@]}" #loop over query array
do

CD=( "&for=congressional%20district:03&in=state:26" "&for=congressional%20district:19&in=state:36" ) #define list of places to run query.  Congressional districts (2-digit numbers) and state FIPS codes.  You can put in as many as you want
#CD=( "&for=congressional%20district:03&in=state:26" ) #single for testing purposes

for i in  "${CD[@]}" #loop over places array
do
#url="https://api.census.gov/data/2016/acs/acs5?get=NAME,B01001_001E&for=congressional%20district:03&in=state:26"
url="https://api.census.gov/data/$year/acs/$dataset?get=NAME,$q$i&key=INSERTYOURKEYHERE" #insert the query and congressional district strings into the API call
#url="https://api.census.gov/data/$year/acs/$dataset?get=NAME,$q$i"
page=$(curl -sL "$url" ) #curl the census API

data=$(echo $page | grep -ioP "(?s)(?<=[a-z]\"\,\")\d.*?(?=\"\,\"\d\d\"\,\"\d\d)") #extract just the query result from json package (after the state name, before the state FIPS and district FIPS)

######BEGIN HUMAN-READABLE LABEL SECTION - copy this pattern for whatever variables and locations that apply to your project#####
#translate states and districts into English
if [ "$i" == "&for=congressional%20district:03&in=state:26" ]
then
  state="MI"
  district="03"
fi
if [ "$i" == "&for=congressional%20district:19&in=state:36" ]
then
  state="NY"
  district="19"
fi

#translate UC Census variables into English
if [ "$q" == "B01001_001E" ]
then
  q_human="total_pop"
fi
######END LABEL SECTION#####

echo "$state-$district | $data | $q_human | $dataset | $year" #output to sdout
echo "$state-$district|$data|$q_human|$dataset|$year" >> $q_human.txt #output to pipe-separated text file.

done
done
