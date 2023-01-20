#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c";

echo -e "\n~~~~~ MY SALON ~~~~~\n";
echo -e "\nWelcome to My Salon, how can I help you?\n";

MAIN_MENU() {
  # list the available services
  LIST_SERVICES;

  # read user input
  read SERVICE_ID_SELECTED;

  # if the service does not exist
  until [[ $SERVICE_ID_SELECTED -ge 1 && $SERVICE_ID_SELECTED -le $NUMBER_OF_SERVICES ]]
  do
    echo -e "\nI could not find that service. What would you like today?";
    LIST_SERVICES;
    read SERVICE_ID_SELECTED;
  done

  echo -e "\nWhat's your phone number?";
  # get phone number
  read CUSTOMER_PHONE;
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'");

  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for name if not in DB
    echo -e "\nI don't have a record for that phone number, what's your name?";
    read CUSTOMER_NAME;
    # insert customer (name, phone) into DB
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')");
  fi

  # schedule appointment
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED");
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?";
  read SERVICE_TIME;
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'");
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')");

  # feedback message
  echo -e " \nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n";
}

LIST_SERVICES() {
  # number of services in DB
  NUMBER_OF_SERVICES=$($PSQL "SELECT COUNT(name) FROM services");

  if [[ $NUMBER_OF_SERVICES -lt 1 ]]
  then
    # if there are no services
    echo -e "\nThere are no services available currently. Sorry for that.";
  else
    # list the services
    for (( i = 1; i <= $NUMBER_OF_SERVICES; i++ ))
    do
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$i");
      echo "$i) $SERVICE";
    done
  fi
}

MAIN_MENU;