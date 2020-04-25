#Work out where each hospital is in CCP UK data
library(RCurl)
library(tidyverse)

# The API call can randomly fail
# Let's try at least 5 times before we give up
tries = 0
# by default, NA gets the class "logical"
data = NA
while (tries == 0 | (tries < 5 & class(data) == "try-error")){
  data = try(postForm(
    uri='https://ncov.medsci.ox.ac.uk/api/',
    token=Sys.getenv("ccp_token"),
    content='record',
    format='csv',
    type='flat',
    'fields[0]'='subjid',
    rawOrLabel='raw',
    rawOrLabelHeaders='raw',
    exportCheckboxLabel='false',
    exportSurveyFields='false',
    exportDataAccessGroups='true',
    returnFormat='json'
  ))
  tries = tries + 1
  # let's wait a second letting the API cool off
  Sys.sleep(1)
}
ccp_ids = read_csv(data, na = "", guess_max = 20000) %>% select(-redcap_repeat_instrument, - redcap_repeat_instance)

# The API call can randomly fail
# Let's try at least 5 times before we give up
tries = 0
# by default, NA gets the class "logical"
data_label = NA
while (tries == 0 | (tries < 5 & class(data_label) == "try-error")){
  data_label = try(postForm(
    uri='https://ncov.medsci.ox.ac.uk/api/',
    token=Sys.getenv("ccp_token"),
    content='record',
    format='csv',
    type='flat',
    'fields[0]'='subjid',
    rawOrLabel='label',
    rawOrLabelHeaders='raw',
    exportCheckboxLabel='false',
    exportSurveyFields='false',
    exportDataAccessGroups='true',
    returnFormat='json'
  ))
  tries = tries + 1
  # let's wait a second letting the API cool off
  Sys.sleep(1)
}
ccp_ids_labelled = read_csv(data_label, na = "", guess_max = 20000) %>% select(-redcap_repeat_instrument, - redcap_repeat_instance)

ccp_ids %>% 
  mutate(dag_id = gsub("\\-.*","", subjid)) -> ccp_ids

ccp_ids_labelled %>% 
  mutate(dag_id = gsub("\\-.*","", subjid)) -> ccp_ids_labelled

rm(data, data_label, tries)