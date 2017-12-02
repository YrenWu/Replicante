Replicante
===================

----
## Test de GlusterFS dans des conteneurs Docker

Créer le réseau et lancer les conteneurs:

```bash
./launch.sh bash
```

Rentrer dans les conteneurs:

`docker-exec -it node-1 /bin/bash`
`docker-exec -it node-2 /bin/bash`


#### Sondes 

En rentrant dans le conteneur on lance le démon GlusterFS, et on lui ajoute l'adresse IP de l'autre conteneur avec la commande `gluster peer probe` pour la reconnaissance entre noeuds.

```
[root@a59def5a9be4 /]# service glusterd start
Redirecting to /bin/systemctl start glusterd.service
[root@a59def5a9be4 /]# gluster peer probe 172.18.0.20
peer probe: success. 
[root@a59def5a9be4 /]# gluster peer status
Number of Peers: 1

Hostname: 172.18.0.20
Uuid: f86c12cc-905b-44fe-af5b-9c0018414ad2
State: Peer in Cluster (Connected)
```
-------

Dans l'autre conteneur pas besoin d'ajouter d'adresse IP, une fois le démon lancé il reconnait automatiquement son pair. On peut le constater avec la commande `gluster peer status` qui liste les noeuds du cluster.

```
[root@96e1d98012d0 /]# service glusterd start
Redirecting to /bin/systemctl start glusterd.service
[root@96e1d98012d0 /]# gluster peer status
Number of Peers: 1

Hostname: node-1.priss
Uuid: ff38aae1-1579-44f9-8e37-5aae68ebbfca
State: Peer in Cluster (Connected)
[root@96e1d98012d0 /]# 
```
