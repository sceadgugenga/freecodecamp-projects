#!/bin/bash
# Set up our vaiables
PSQL="psql --username=freecodecamp --dbname=periodic_table -t  --no-align -c"
re_nums='^[0-9]+$'
INFO_QUERY="SELECT properties.atomic_number, types.type, properties.atomic_mass, properties.melting_point_celsius,properties.boiling_point_celsius, elements.atomic_number, elements.symbol ,elements.name FROM properties JOIN elements ON properties.atomic_number=elements.atomic_number JOIN types ON properties.type_id=types.type_id WHERE "
RETURN_MESSAGE="I could not find that element in the database."

# Parse the script's argument to decide
# if we have an atomic number, a symbol, or a name.
if [[ -z $@ ]]
then
  RETURN_MESSAGE="Please provide an element as an argument."
else
  if [[ $1 =~ $re_nums ]]
  then
     INFO_QUERY+="properties.atomic_number=${1}"
  elif [[ ${#1} -le 2 && ${#1} -ge 1 ]]
  then
     INFO_QUERY+="LOWER(elements.symbol)=LOWER('${1}')"
  else
    INFO_QUERY+="LOWER(elements.name)=LOWER('${1}')"
  fi
  
  # Make the query
  ELEMENT_INFO_STR=$($PSQL "${INFO_QUERY}")

  if [[ -n ${ELEMENT_INFO_STR} ]]
  then
    # Create our variables from SQL output
    # We turn the string into an array and then
    # assign the values of the array element to variables
    IFS="|" read -r -a ELEMENT_INFO <<< $ELEMENT_INFO_STR 
    ATOMIC_NUMBER=${ELEMENT_INFO[0]}
    ELEMENT_TYPE=${ELEMENT_INFO[1]}
    ELEMENT_MASS=${ELEMENT_INFO[2]}
    ELEMENT_MELTING=${ELEMENT_INFO[3]}
    ELEMENT_BOILING=${ELEMENT_INFO[4]}
    ELEMENT_SYMBOL=${ELEMENT_INFO[6]}
    ELEMENT_NAME=${ELEMENT_INFO[7]}

    # Change the return message to provide element info
    RETURN_MESSAGE="The element with atomic number ${ATOMIC_NUMBER} is ${ELEMENT_NAME} (${ELEMENT_SYMBOL}). It's a ${ELEMENT_TYPE}, with a mass of ${ELEMENT_MASS} amu. ${ELEMENT_NAME} has a melting point of ${ELEMENT_MELTING} celsius and a boiling point of ${ELEMENT_BOILING} celsius."
  fi
fi
echo ${RETURN_MESSAGE}
