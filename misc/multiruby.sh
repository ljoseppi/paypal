#!/bin/bash

for i in 1.9.2-head 1.9.1 ree 1.8.7; do
  rvm use $i && echo `ruby -v` && bundle install > /dev/null && bundle exec rake spec && bundle show
done