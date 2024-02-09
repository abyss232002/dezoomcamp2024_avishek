## Setting up the Environment on Google Cloud (Cloud VM + SSH access) from a local linux environment(_wsl2_)
* Create a new project in GCP.

![Alt text][def]
* Create a vm instance by selecting top left hamburger menu
  
  ![Alt text][def2]
* Enable the API
  
  ![Alt text][def3]

* Generating [SSH keys][def4]
  * Replace **FILE_NAME** and **USER_NAME** in below command in your local bash terminal
  ``` sh
  ssh-keygen -t rsa -f ~/.ssh/FILE_NAME -C USER_NAME -b 2048
  ```
  * You can keep the passphrase empty in case you want to avoid putting passphrase every time you connect
  * Do a ```ls -l``` command you should see one private and one public key
  ```sh
  16:49 gcp
  16:49 gcp.pub
  ```
  * Add the ssh key inside your .pub file in Metadata/SSH KEYS section of your gcp UI and click on save in bottom left
  
  ![Alt text][def5] 
  * On top of UI page you will see **_All instances in this project inherit these SSH keys_**

* Creating a virtual machine on GCP
  Create a 4vcpu + 16 GB ram +30 GB blalanced persistent disk VM instance with Ubuntu 20.04 LTS(Debian is fine too)

  ![Alt text][def6] 

* Connecting to the VM with SSH
  * Note the external ip address once the VM instance is created
   
  ![Alt text][def7] 
  * connect from your local bash terminal using **private ssh key**,external ip address of the ip,user_name used to create the ssh keys and command

```sh 
 ssh -i ~/.ssh/PRIVATE_KEY_FILE_NAME USER_NAME@<external ip of VM instance in cloud>
```  
  * Run command ```htop``` after connection established to interactively monitor your system's vital resources or server processes in real-time.Make sure it is a 4 core 16 gb machine
  
  ![Alt text][def8]
  * Run ```gcloud version``` to check version
  
  ![Alt text][def9]

* Installing Anaconda
  * Run ```wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh``` for anaconda installation in remote vm
  * 
* Creating SSH config file
  * Create config file at ```~/.ssh``` in wsl2 and ```C:/Users/ayana/.ssh/``` folder and update below details.
  * **I copied public and private key part from wsl2** ```~/.ssh``` folder to windows folder
  * Next time onwards we can connect our VM stance by typing ```ssh <alias_name>```
```sh
    Host dezoomcamp2024 -->alias name
    Hostname <external ip of vm instance>
    User abyssde232024 -->user
    IdentityFile ~/.ssh/gcp --> private key
``` 
* Accessing the remote machine with VS Code and SSH remote
  * logout **ctrl+D** and login again by typing ```ssh <alias_name>``` or alternately type ```source bashrc```
  * The prompt should show ```(base)``` at the begining which says Anconda is initialzed
  * Run ```which python``` to check where the python path was set
  * Run python in the prompt and ```py import pandas as pd``` and check ```py pd.__version__```. ```exit()```
  * In windows/wsl2 create a folder in root as ```.ssh``` and prepare a config file with below details.
    * Linux Machine
```sh
  Host dezoomcamp2024 -->alias_name
      Hostname <external ip of VM instance in cloud>
      User abyssde232024-->user name
      IdentityFile ~/.ssh/gcp-->private key location in wsl2
``` 
  * Windows Machine
  
```sh
Host dezoomcamp2024
    HostName <external ip of VM instance in cloud>
    User abyssde232024-->user name
    IdentityFile C:/Users/xxxx /.ssh/gcp-->private key location in windows
``` 
  * The config file will be used to connect to remote vm instance by command ```ssh <alias name>```
  * Make sure to install **_Remote - SSH_** , **_Remote - SSH: Editing Configuration Files_** , **_Google Cloud Platform SSH_**

![Alt text][def10]

* Installing Docker by typing```sudo apt-get update``` to update apt-get packages and then ```sudo apt install docker.io```
  * Run ```docker run hello-world``` and terminal will throw below error
```sh
(base) abyssde232024@dezoomcamp2024:~$ docker run hello-world
docker: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create": dial unix /var/run/docker.sock: connect: permission denied.
See 'docker run --help'.
```
  * Follow the link [docker-without-sudo][def11] and execute the steps to resolve the error
  
* Installing docker-compose from latest [release][def12] and download in ```~./bin``` and save it as **docker-compose** by running below command
```sh
wget https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -O docker-compose
```
  * run ```chmod 755 docker-compose``` to make docker-compose in executable mode in remote vm instance
  * run ```./docker-compose version``` to check installation accuracy
  * now we want to make it visible for any directory and for that add location to the PATH variable
  * open ```.bashrc``` and add below lines of code
```sh
export PATH="${HOME}/bin:${PATH}"
```
  * Press ```ctrl+O``` to save it(write out) and ```ctrl+X``` to exit
  * logout and login to remote instance again or run ```source .bashrc``` to take new override in effect
  * run ```which docker-compose``` to make sure PATH variable is updated
  * run ```docker-compose version``` . Check this time we **do not** use ```./``` before the command to indicate the path
  * change directory to ```~/data-engineering-zoomcamp/01-docker-terraform/2_docker_sql``` and run ```docker-compose up -d```
  * run ```docker ps``` to check the container up and running
  
* Installing pgcli by running ```pip install pgcli```
  * If you want to install from Conda following below steps, **_solving envirinment_** step will take for ever even though forge server is up and running.
```bash
conda install -c conda-forge pgcli
pip install -U mycli
``` 
  * I tried below steps first as suugested in [conda site](https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community)
```sh
  conda update -n base conda
  conda install -n base conda-libmamba-solver
  conda config --set solver libmamba
  ```
  * and after that
```bash
conda install -c conda-forge pgcli
pip install -U mycli
```
  * **but still throwing error**.So the conclusion is at this point move ahead with ```pip install pgcli```. **Also removing pgcli pacjage installed by Conda was giving me error when I reinstalled pgcli through pip. _So be careful_**
  * log in to pgcli run ```pgcli -h localhost -p 5432 -u root -d ny_taxi -W```
  * after logging in type ```\d```--->describe table
  * you should be able to see
```sh
Server: PostgreSQL 13.13 (Debian 13.13-1.pgdg120+1)
Version: 4.0.1
Home: http://pgcli.com
root@localhost:ny_taxi> \d
+--------+------+------+-------+
| Schema | Name | Type | Owner |
|--------+------+------+-------|
+--------+------+------+-------+
SELECT 0
Time: 0.013s
root@localhost:ny_taxi>
```
* Port-forwarding with VS code: connecting to pgAdmin and Jupyter from the local computer
  * To forward port through vscode enable following settings 
  * open remote instance of vm through vscode and add port 5432 to forward pgcli from remote vm to our local machine(localhost) port 5432
  * 
![Alt text][def13]
  * open pgcli from local host(wsl2) of local machine by typing ```pgcli -h localhost -p 5432 -u root -d ny_taxi -W```
  * **It will not connect to localhost:5432 stating the service is not accepting tcp/ip connection**. I have tried to change vscode setting for remote and running postgres docker from root of remote instance **but it still doesn't work**
  * Forward port 8080(pgAdmin) and 8000(jupyter notebook) and you should be able to access it,but **pgAdmin will not be able to connect your localhost:5432(postgres)** with similar problem.At this point **as per suggestion from Alex we are moving forward.**
  * From Jupyter notebook in local host connecting remote instance will be able to exeute python script.But if you are using sqlalchemy to connect postgres docker instance at port 5432 of remote instance where conda is installed install psycopg2 following ```conda install anaconda::psycopg2```. ```pip install psycopg2``` will not work and installing ```pip install psycopg2-binary``` won't solve the problem of connection postgres at 5432. **So move ahead**. May be next time we will not try to install conda at all and see the outcome.**_I don't think it is a problem of Conda though**
  
# **Yet to update notes for below topic**
* To authenticate create a service account,create key and download the key in your local machine
  * Now create a service account and generate keys like shown in the videos
  * Download the key and put it to some location, e.g. ``` .gc/terraformdemo2024-413709-02a2b43003f7.json ``` via sftp
  * Set ```GOOGLE_APPLICATION_CREDENTIALS``` to point to the file
  * export ```GOOGLE_APPLICATION_CREDENTIALS=~/.gc/terraformdemo2024-413709-02a2b43003f7.json```
  Now authenticate:

```sh
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```
Alternatively, you can authenticate using OAuth like shown in the video

gcloud auth application-default login
If you get a message like quota exceeded

WARNING: Cannot find a quota project to add to ADC. You might receive a "quota exceeded" or "API not enabled" error. Run $ gcloud auth application-default set-quota-project to add a quota project.

Then run this:

PROJECT_NAME="terraformdemo2024"
gcloud auth application-default set-quota-project ${PROJECT_NAME} 
* Installing Terraform
  * got to ```~/bin``` and run ```wget https://releases.hashicorp.com/terraform/1.7.3/terraform_1.7.3_linux_amd64.zip```
  * run ```sudo apt-get install unzip``` because you probably don't have unzip
  * remove ```terraform_1.7.3_linux_amd64.zip```
  * go to the folder with main.tf and variable.tf in ```/home/abyssde232024/1_terraform_gcp``` and run ```terraform init``` 
* Using sftp for putting the credentials to the remote machine
* Shutting down and removing the instance
  * ```sudo shutdown now```

[def]: ./Images/image1.png
[def2]:./Images/image2.png
[def3]:./Images/image3.png
[def4]: https://cloud.google.com/compute/docs/connect/create-ssh-keys
[def5]: ./Images/image4.png
[def6]: ./Images/image5.png
[def7]: ./Images/image6.png
[def8]: ./Images/image7.png
[def9]: ./Images/image8.png
[def10]:./Images/image9.png
[def11]: https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md
[def12]: https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64
[def13]: ./Images/image10.png