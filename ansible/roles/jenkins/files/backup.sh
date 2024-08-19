#!/bin/bash
tar -czvf /var/backups/jenkins_home_$(date +%F).tar.gz /var/lib/jenkins
