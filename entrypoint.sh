#!/bin/bash

ruby ./helpers/wait_for_documentserver_start.rb
rspec $CURRENT_SPEC
