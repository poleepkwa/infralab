infralab
========

```bash
# install microstack
sudo snap install microstack --classic --beta
sudo snap enable microstack
sudo microstack.init --auto
cp $HOME/.ssh/id_microstack .

# http://10.20.20.1
# username: admin
# password: keystone

# add centos7 image
wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
unxz CentOS-7-x86_64-GenericCloud.qcow2.xz
microstack.openstack image create --disk-format qcow2 --container-format bare \
  --public --file ./CentOS-7-x86_64-GenericCloud.qcow2 centos7
microstack.openstack image list

# create mini flavor
microstack.openstack flavor create m1.mini --id auto --ram 1024 --disk 10 --vcpus 1
microstack.openstack flavor list


# create bin folder
mkdir bin
cd bin


# install terraform
wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
unzip terraform*.zip
rm terraform*.zip


# install rke
wget https://github.com/rancher/rke/releases/download/v1.1.2/rke_linux-amd64
mv rke_linux-amd64 rke
chmod +x rke


# install kubectl
wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl


# install helm
wget https://get.helm.sh/helm-v3.2.3-linux-amd64.tar.gz
tar -zxvf helm*.tar.gz
mv linux-amd64/helm .
rm -fr helm-v3.2.3-linux-amd64.tar.gz linux-amd64
cd ..


# provision
bin/terraform init
bin/terraform apply -target module.rke

ips=(10.20.20.11 10.20.20.12 10.20.20.13 10.20.20.21 10.20.20.22 10.20.20.31 10.20.20.32 10.20.20.33)
for ip in ${ips[@]}; do
  ssh-keygen -f $HOME/.ssh/known_hosts -R $ip
  ssh -o "StrictHostKeyChecking no" -i id_microstack centos@$ip <<EOF
sudo yum -y install epel-release
sudo yum -y install htop
curl https://releases.rancher.com/install-docker/18.09.2.sh | sh
sudo usermod -aG docker centos
sudo systemctl enable docker
EOF
done

bin/rke up --config targets/rke/cluster.yml
export KUBECONFIG=$(pwd)/targets/rke/kube_config_cluster.yml
kubectl top nodes
bin/helm list


# stop
sudo snap disable microstack


# start
sudo snap enable microstack
microstack.openstack server start etcd1
microstack.openstack server start etcd2
microstack.openstack server start etcd3
microstack.openstack server start control1
microstack.openstack server start control2
microstack.openstack server start worker1
microstack.openstack server start worker2
microstack.openstack server start worker3

export KUBECONFIG=$(pwd)/targets/rke/kube_config_cluster.yml
bin/kubectl top nodes
bin/helm list
```
