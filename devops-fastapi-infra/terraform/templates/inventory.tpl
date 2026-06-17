[masters]
%{ for index, ip in master_ips ~}
master-${index + 1} ansible_host=${ip} ansible_user=${ssh_user}
%{ endfor ~}

[workers]
%{ for index, ip in worker_ips ~}
worker-${index + 1} ansible_host=${ip} ansible_user=${ssh_user}
%{ endfor ~}

[services]
services-1 ansible_host=${services_ip} ansible_user=${ssh_user}

[k8s_cluster:children]
masters
workers

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ProxyCommand="ssh -i ${jump_private_key_file} -o IdentitiesOnly=yes -W %h:%p ${jump_user}@${proxmox_host}"'
ansible_ssh_private_key_file=${ssh_private_key_file}
ansible_become=true