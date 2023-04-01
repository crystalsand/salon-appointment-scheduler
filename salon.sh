#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SELECT_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services list
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display services list
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # ask for a service
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to service list
    SELECT_SERVICE "That is not a valid service number."
  fi

  # get service availability
  AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if no service available
  if [[ -z $AVAILABLE ]]
  then
    # send to service list
    SELECT_SERVICE "I could not find that service. What would you like today?"

  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get selected service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # get appointment
    echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # insert appointment info
    INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
}

echo "Welcome to My Salon, How can I help you?"
# display available services
SELECT_SERVICE

