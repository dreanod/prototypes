#!/bin/bash

# compile the C function
make

# Copy the function to the home of postgres user
sudo cp funcs.so /opt/local/var/db/postgresql93/funcs.so

# Declare the function and test it 
psql -U postgres -d dd -f create_c_user_function.sql

# test user function (the query should return 2)
psql -U postgres -d dd -f test_c_user_function.sql