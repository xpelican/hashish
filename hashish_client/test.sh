#!/bin/bash

text_variable="test_string"
variable="2"

if [ "$text_variable" = "test_string" ]; then
echo "text_variable is equal to test_string"
else
echo "text_variable is NOT equal to test_string"
fi

echo -e "---------------------------------------------------"


if [ "$variable" -gt 1 ] ; then
echo "variable is greater than 1"
fi


if [ "$variable" -eq 1 ] ; then
echo "variable is equal to 1"
fi

if [ "$variable" -lt 1 ] ; then
echo "variable is less than 1"
fi

echo -e "$text_variable"
echo -e "$variable"
