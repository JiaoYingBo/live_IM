# live_IM（直播项目的即时通信模块）
TCP提供的是可靠的链接，双方直接进行通信，UDP是不可靠链接，双方不是直接通信。

* 建立 TCP Socket 链接过程：

    Server: 初始化socket->绑定IP和端口->listen（开启监听）->accept（接收到socket连接）

    Client: 初始化socket->指定IP和端口->connect（建立连接）

* 建立 UDP Socket 链接过程：

    Server: 初始化socket->绑定IP和端口号->Recvfrom(开始接收)

    Client: 初始化socket->指定IP和端口号->Sendto（开始发送）

#### 通信协议：使用ProtocolBuffer（简称PB）

PB具有跨平台，序列化反序列化，数据量小等优点，它支持C++/Python/Java/OC/Swift等多种语言，可以直接将对象序列化成Data。

安装ProtocolBuffer运行
