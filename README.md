# cloud-native

### Overview

1. Jenkins VM
- Hosts Jenkins, Docker and Ansible.
- Builds docker images and pushes them to registry

2. Docker registry
- Hosted on Docker hub

3. K8s cluster VM
- Hosted on a VM, where the app will be deployed

4. GitHub repository
- Repo where the committed code triggers the Jenkins pipelines



### Workflow plan

- Jenkins listens for changes in GitHub and triggers the pipeline
- Jenkins builds a docker image of the app, tags it and pushes to Docker registry
- Image is deployed to the k8s cluster