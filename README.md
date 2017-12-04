# 使用kubernetes部署Hyperledger Fabric

本文假设你已经搭建好了k8s集群，在此基础上，依本文步骤即可在K8s上部署Hyperledger Fabric


1. #### 克隆本仓库

    ```
    git clone https://github.com/marryton007/hyperledger-fabric-k8s.git
    ```
    
2. #### 准备好NFS服务器
    这里以192.168.1.206作为NFS服务器，后面的Peer，order，ca都会共享该服务器
    
    ```
    showmount -e 192.168.1.206
    Exports list on 192.168.1.206:
    /data                               *
    /opt/share                          *
    ```
        
2. #### 启动kafka服务

    ```
    cd hyperledger-fabric-k8s/fabric_on_kubernetes/Fabric-on-K8S/k8s_kafka
    ./run.sh
    ```
    
    检测kafka服务是否启动
    
    ```
    kubectl get pod -n kafka
    ```

2. #### 启动Orderer，Peer，CA，cli节点

    ```
    cd hyperledger-fabric-k8s/fabric_on_kubernetes/Fabric-on-K8S/setupCluster
    
    // 以mac系统为例，加载NFS目录
    sudo mount -o resvport,rw -t nfs 192.168.1.206:/opt/share /opt/share
    sudo mount -o resvport,rw -t nfs 192.168.1.206:/data /opt/data
    
    // 在/opt/data目录中创建子目录，供orderer,peer,cli,ca使用
    ./mkdir-storage-dir.sh
    
    // 生成证书及相关的k8s部署文件，首次使用的用户需要下载Fabric相关工具，
    // 如cryptogen,configtxgen，请参考'Hyperledger fabric示例'
    ./generateALL.sh
    
    // 使用kubectl创建相关资源
    python3 transform/run.py
    ```
    
3. #### 测试

    ```
    // 列出org下pods
    kubectl get pods --namespace org1
    
    // 进行容器
    kubectl exec -it cli-dcb6c5f89-gvzrl bash --namespace=org1
    
    // 创建通道
    peer channel create -o orderer0.orgorderer1:7050  -c mychannel -f ./channel-artifacts/channel.tx -t 60
    
    cp mychannel.block ./channel-artifacts
    
    // 加入通道
    peer channel join -b ./channel-artifacts/mychannel.block
    
    // 更新 anchor peer，每个 org 只需执行一次
    peer channel update -o orderer0.orgorderer1:7050  -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx
    
    // 安装 chaincode
    peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/peer/channel-artifacts/chaincode_example02
    
    // 实例化 chaincode
    peer chaincode instantiate -o orderer0.orgorderer1:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'  -P "OR ('Org1MSP.member','Org2MSP.member')"
    
    // 查询
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
    
    // 调用
    peer chaincode invoke -o orderer0.orgorderer1:7050   -C mychannel -n mycc -c '{"Args":["invoke","a","b","10"]}'
    ```    

3. #### 参考资源
    * [Kubernetes集群之Kafka和ZooKeeper][k8s-kafka-zk]
    * [用Kubernetes部署超级账本Fabric的区块链即服务][fabric-on-k8s]
    * [Hyperledger fabric示例][fabric-sample]

[k8s-kafka-zk]:https://o-my-chenjian.com/2017/04/11/Deploy-Kafka-And-ZP-With-K8s/
[fabric-on-k8s]:https://github.com/hainingzhang/articles
[fabric-sample]:http://hyperledger-fabric.readthedocs.io/en/latest/samples.html


