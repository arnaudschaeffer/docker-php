#!/bin/bash

set -x

. /apache-template.sh

. /update_user.sh

exec "apache2-foreground"