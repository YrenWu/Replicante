Replicante
===================

----
## Test de GlusterFS dans des conteneurs Docker

Créer le réseau et lancer les conteneurs:

```bash
./launch.sh 
```

Rentrer dans les conteneurs:

`docker exec -it node-1 /bin/bash`   
`docker exec -it node-2 /bin/bash`


#### Sondes 

En rentrant dans le conteneur on lance le démon GlusterFS, et on lui ajoute l'adresse IP de l'autre conteneur avec la commande `gluster peer probe` pour la reconnaissance entre noeuds.

```
[root@a59def5a9be4 /]# service glusterd start
Redirecting to /bin/systemctl start glusterd.service
[root@a59def5a9be4 /]# gluster peer probe 172.66.0.20
peer probe: success. 
[root@a59def5a9be4 /]# gluster peer status
Number of Peers: 1

Hostname: 172.66.0.20
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


-------
http://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/

### Volume distribué

> Dans un volume distribué, les fichiers sont répartis de manière aléatoire entre les briques du volume. 
> Utilisez des volumes distribués lorsque vous avez besoin d'augmenter le stockage et que la redondance n'est pas importante ou est fournie par d'autres couches matérielles / logicielles.

Monter un volume à partir d'un des deux conteneurs

`gluster volume create volume-distibuted node-1:/tmp/exp1 node-2:/tmp/exp2 force`

Démarrer le volume, cette commande démarre le volume des deux cotés 

```bash 
$ gluster volume start volume-distibuted
  volume start: volume-distibuted: success
```

Pour avoir les informations sur un volume

```bash 
$ gluster volume info
 
  Volume Name: volume-distibuted
  Type: Distribute
  Volume ID: 442c929b-71bf-4fd2-8e4c-fa288f4f859e
  Status: Started
  Snapshot Count: 0
  Number of Bricks: 2
  Transport-type: tcp
  Bricks:
  Brick1: node-1:/tmp/exp1
  Brick2: node-2:/tmp/exp2
  Options Reconfigured:
  transport.address-family: inet
  nfs.disable: on
```

Le mode distribué est le mode par défaut de GlusterFS. Les fichiers sont répartis sur les noeud et il n'y a pas de redondance. On peut ajouter facilement des noeuds au cluster mais en cas de perte de l'un d'entre eux, les données qu'il contient seront perdues.

### Volume répliqué

### Volume strippé

### Volume distribué-répliqué
