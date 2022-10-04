#!/bin/bash

for i in "$@"; do
  case $i in
    -f|--fastpath)
      EXECUTION_PATH="fastpath"
      EXECUTION="-f"
      shift # past argument=value
      ;;
    -s|--slowpath)
      EXECUTION_PATH="slowpath"
      EXECUTION=""
      shift # past argument=value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

if [[ -z $EXECUTION_PATH ]]
then
  echo "No argument provided"
  exit 1
fi
