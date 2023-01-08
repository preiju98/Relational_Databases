#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
 echo Please provide an element as an argument.
else
  # check if input is integer or string
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # check if element is in database with atomic number
    INPUT_RESULT=$($PSQL "SELECT atomic_number FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1")
    int_value=1
  else
    # if input is a string check symbol or name
    INPUT_RESULT=$($PSQL "SELECT symbol, name FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1' OR name = '$1'")
    int_value=2
  fi
  
  #ELEMENT_INPUT_RESULT=$($PSQL "SELECT atomic_number FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1 OR symbol = '$1' OR name = '$1'")
  if [[ -z $INPUT_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    if [[ $int_value == 1 ]]
    then
      RESULTS=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1")
    else
      RESULTS=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1' OR name = '$1'")
    fi

    echo $RESULTS | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi

