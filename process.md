# 流程

## 前台发送一般的命令

1. 前台线程往 `task_todo` 插一条记录
2. StarRiver服务从 `task_todo` 读记录
3. StarRiver服务执行，对相关的表进行必要的更新，然后把结果写到 `task_done` 。
4. 前台线程从 `task_done` 读结果，去相应表读数据，然后显示。

##	前台上载文件

暂定：配置一个文件服务器，协议可以从 FTP、HTTP、Samba、NFS 中选择。

前台程序往服务器上传一个文件后记录该文件的 URI 。

StarRiver服务通过参数中读到的 URI 提取该文件。
