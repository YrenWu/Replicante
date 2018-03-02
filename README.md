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
# gluster volume start volume-distributed
  volume start: volume-distibuted: success
```

Pour avoir les informations sur un volume

```bash 
# gluster volume info
 
  Volume Name: volume-distributed
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

#### Tester la distribution 


- Dans le client 

Créer le point de montage `mkdir /data`
Monter le volume à partir du client avec `mount -t glusterfs node-1:volume-distributed /data`
Création de fichiers 

```
echo "Bonjour monde" >  /data/test
echo "Bonjour monde" >  /data/test2
echo "Bonjour monde" >  /data/test3
```

Des fichiers `test`, `test2` et `test3` sont crées sur notre client et sont répartis sur les des deux noeuds du cluster sans répication.

- Noeud 1 

```
cat /tmp/exp1/test
"Bonjour monde"

ls /tmp/exp1
.glusterfs/ 
test        
test2   
```

- Noeud 2

```
ls /tmp/exp2
.glusterfs/ 
test3

cat /tmp/exp2/test3
"Bonjour monde"
```

Sur un volume répliqué le fichier apparaitra dans les deux noeuds.

### Volume répliqué

> Les volumes répliqués créent des copies de fichiers sur plusieurs briques du volume. Cela permet d'améliorer la disponibilité et fiabilité du système.

Création du volume répliqué avec deux noeuds :

`gluster volume create volume-replica replica 2 transport tcp node-1:/tmp/exp1 node-2:/tmp/exp2 force`

Démarrer le volume :

`gluster volume start volume-replica`

 
```bash
# gluster volume info
  
  Volume Name: volume-replica
  Type: Replicate
  Volume ID: 436a9307-9e24-4123-945e-1a0e1c43ec83
  Status: Started
  Snapshot Count: 0
  Number of Bricks: 1 x 2 = 2
  Transport-type: tcp
  Bricks:
  Brick1: node-1:/tmp/exp1
  Brick2: node-2:/tmp/exp2
  Options Reconfigured:
  transport.address-family: inet
  nfs.disable: on
```

#### Démarrer le volume

```
[root@cfcd00872eed /]# gluster volume start volume-replica
volume start: volume-replica: success
```

Dans un des deux noeuds, on peut vérifier que le volume est démarré avec :

```bash
# gluster volume status

  Status of volume: volume-replica
  Gluster process                             TCP Port  RDMA Port  Online  Pid
  ------------------------------------------------------------------------------
  Brick node-1:/tmp/exp1                      49152     0          Y       496  
  Brick node-2:/tmp/exp2                      49152     0          Y       394  
  Self-heal Daemon on localhost               N/A       N/A        Y       517  
  Self-heal Daemon on 172.66.0.20             N/A       N/A        Y       415  
  
  Task Status of Volume volume-replica
  ------------------------------------------------------------------------------
  There are no active volume tasks
``` 


#### Tester la réplication 


- Dans le client 

Créer le point de montage `mkdir /data`
Monter le volume à partir du client avec `mount -t glusterfs node-1:volume-replica /data`
Création d'un fichier `echo "Bonjour monde" >  /data/test`

Un fichier `test` est crée sur notre client et dans les deux noeuds du cluster avec la chaine de caractères "Bonjour monde".
Allons dans nos noeuds ou nous retrouvons notre fichier qui a bien été répliqué.

- Noeud 1 

```
cat /tmp/exp1/test
"Bonjour monde"
```

- Noeud 2

```
cat /tmp/exp2/test
"Bonjour monde"
```

Sur un volume distribué le fichier apparaitra aléatoirement sur un des deux noeuds.
