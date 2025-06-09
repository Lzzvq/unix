# troubleshooting with logs
- as sudo, `tail /var/log/messages` and/or `tail /var/log/secure` 
    - for ssh issues, etc 

# searching for files
rg nessus_scanner_sg */account.hcl | sort

# Check if a java service is running
- e.g. keycloak
- `ps -ef | grep -i java` 

# SonarQube troubleshooting 
- configuration file located at `/opt/sonarqube/sonarqube-8.9.10.61524/conf/sonarqube.properties` (version number obviously changes as necessary)
    - compare from broken environment to working (e.g. dev vs prod)