#!/bin/bash
# Setup Variables
# We are telling psql to seperate the fields with 
# a colon, to help us parse later one 
PSQL="psql --username=freecodecamp --dbname=salon -t --csv -P fieldsep=: --no-align -c"  
SERVICES_LIST_STR='' #String list of services
SERVICE_NAME_SELECTED=''
SERVICE_ID_SELECTED=''
SERVICES_ARRAY=()

# Getting the list of services
# We are saving the a string for display
# We also save them to an array to reduce server calls
SERVICE_LIST_FROM_DB=$($PSQL "SELECT service_id, name FROM services")
for service in ${SERVICE_LIST_FROM_DB[@]}; do
  SERVICES_LIST_STR+="${service%:*}) ${service#*:}\n"
  SERVICES_ARRAY+=("${service%:*}:${service#*:}")  
 done 

echo -e "~~~~~ MY SALON ~~~~~\n"
#### Get services
echo -e "Welcome to My Salon, how can I help you?\n"
echo -e ${SERVICES_LIST_STR}
read SERVICE_ID_SELECTED

# Keep asking about a service until we get a vaild response
while ([[ ! ${SERVICE_LIST_FROM_DB}  =~ ${SERVICE_ID_SELECTED} ]])
do
echo "I could not find that service. What would you like today?"
echo -e ${SERVICES_LIST_STR}
read SERVICE_ID_SELECTED
done

# We pull the name of the service from the array
# using the service number
SERVICE_NAME_SELECTED="${SERVICES_ARRAY[$SERVICE_ID_SELECTED-1]#*:}"

### Get phone number
echo -e "What's your phone number?\n"
read CUSTOMER_PHONE
CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='${CUSTOMER_PHONE}'")
if [[ -z ${CUSTOMER_INFO} ]]
then
  echo -e "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(name,phone) VALUES('${CUSTOMER_NAME}','${CUSTOMER_PHONE}')")
  if [[ ${CUSTOMER_INSERT} == "INSERT 0 1" ]]
  then
    CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='${CUSTOMER_PHONE}'")
  fi
fi

# We are parsing our returned data
# into customer name and id
CUSTOMER_ID="${CUSTOMER_INFO%:*}" 
CUSTOMER_NAME="${CUSTOMER_INFO#*:}" 

### Get appoinment time
echo -e "What time would you like your ${SERVICE_NAME_SELECTED}, ${CUSTOMER_NAME}?"
read SERVICE_TIME
APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES(${CUSTOMER_ID}, ${SERVICE_ID_SELECTED}, '${SERVICE_TIME}')")
if [[ ${APPOINTMENT_INSERT} == "INSERT 0 1" ]]
then 
echo  "I have put you down for a ${SERVICE_NAME_SELECTED} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."
else
echo "I was unable to book your appointment"
fi
