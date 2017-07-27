### OpenVPN iOS OSX 封装

利用子模块方式集成OpenVPN3和相应的库。

**1.集成到项目中**

  项目中已经有生成好的lz4/mbedtls/asio/openvpn3库，使用carthage集成到项目中生成动态库
  
**2.开发库文件**

  1.将工程clone到你的工程目录下  
  
  2.将子模块clone下来，命令是 git submodule update --init --recursive  
  
  3.打开终端,cd 到你clone的目录下  
  
  4.输入 $OVPN_PATH=`pwd`  
  
  5.执行build-all文件，命令是 . build-all. 
