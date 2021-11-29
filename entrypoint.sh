#!/bin/bash

ruby ./helpers/wait_for_documentserver_start.rb
rspec spec/convertion_by_format/$CURRENT_SPEC
