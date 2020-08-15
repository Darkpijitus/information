#!/bin/bash

crontab /etc/cron.d/tsv_crontab \
&& cron \
&& . /usr/local/bin/apache2-foreground
