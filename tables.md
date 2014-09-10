# 表结构

除特殊说明外，每张表的第一个字段为主键 (Primary Key)。

## SystemConfig

| 字段名 | 类型 | 含义 | 备注 |
| --- | --- | --- | --- |
|idSystemConfig|int unsigned AUTO_INCREMENT|||
|NetworkMode|tinyint unsigned|StarRiver服务角色|0: 服务器, 1: 客户端。考虑同时作为多种角色与不同控制器通信的需求|
|NetworkPort| smallint unsigned| 服务器侦听端口||
|LastServerActivity|timestamp| StarRiver服务最近连接时间|StarRiver服务定时更新这个字段。|
|IntervalReportActivity|int unsigned|更新最近连接时间间隔||
|IntervalAutoStatusQuery |int unsigned|自动查询控制器状态间隔||
|IntervalAutoDeviceStatusQuery| int unsigned|自动查询设备状态间隔||
|IntervalRetryWrite|int unsigned|连接建立期间，写操作重试间隔|单位为毫秒|
|IntervalKeepalive| int unsigned|心跳包发送间隔||
|TimeoutCmdAck| smallint unsigned| 指令响应超时|CSA 6.1 T1|
|TimeoutCmdResult|smallint unsigned|指令结果超时|CSA 6.1 T2|
|TimeoutEventAck |smallint unsigned| 事件响应超时|CSA 6.2 T3|
|TimeoutIdle |smallint unsigned |通信空闲时间|CSA 6.3 T4|
|TimeoutKeepaliveAck |smallint unsigned| 心跳响应超时|CSA 6.3 T5|
|RetryCmd|tinyint unsigned|指令重试次数|CSA 6.1 N1|
|RetryEvent|tinyint unsigned|事件重试次数|CSA 6.2 N2|
|RetryKeepalive|tinyint unsigned|心跳重试次数|CSA 6.3 N3|
|MapFormat| int|地图类型|0: BMP, 1: GIS|

## User

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idUser|int unsigned|||
|Username|varchar(64)| ||
|MD5| varchar(40) |MD5(username+password)|128-bit, 32 digits long hex string|
|Admin| tinyint|用户权限|0: StarRiver服务; 1: 一般用户, 2: 管理员 |
|Note|varchar(450)|备注|UTF8|

默认分配如下两个用户：

|idUser|Username|备注|
| --- | --- | --- |
|0| comm|StarRiver服务|
|1| admin| 管理员|

## Controller

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|||
|Name|varchar(128)|||
|MAC| binary(8)| 8字节控制器地址||
|CommProtocol|tinyint unsigned |通信协议|0: Shanghai, 1: Sansi LC300, 2: CSA|
|DataProtocol|tinyint unsigned |通信方式|0: 串口, 1: TCP, 2: UDP|
|ComPort |varchar(8) |串口号 |COM0, COM1, ttyS0, ttyS1等|
|ComBaud |int unsigned |串口波特率| 9600, 115200等|
|ComAddr |tinyint unsigned |使用485串口通信时指明地址||
|IPAddr|varchar(16) | |xxx.xxx.xxx.xxx|
|IPPort|smallint unsigned | ||
|Note|varchar(450) | 备注|比如位置信息|
|DisplayOrder|int unsigned|前台程序界面上显示的顺序|不宜重复|

## ControllerStatus

状态量不支持查询的话对应字段写 `NULL`。

|字段名 |类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|Controller.idController||
|CommState| tinyint unsigned |通信状态|0: 正常, 1: 故障|
|LoginState|tinyint unsigned |是否已注册到StarRiver服务服务端| 0: 未注册, 1: 已注册|
|VersionSoftware |binary(4) |软件版本||
|VersionSystem| binary(4) |系统版本||
|VersionKernel| binary(4) |内核版本||
|VersionHardware| binary(4) |硬件版本||
|ManufacturerInfo|varchar(450) |厂商信息文本内容|UTF8|
|Type|binary(2) |控制器类型| 上海：0x0001 => 485控制器, 0x0002 => PLC控制器, 0x0003 => 无线控制器。LC300 同上|
|WorkMode|binary(1) |工作模式|上海：0x01 => 远程控制模式, 0x02 => 时控工作模式。LC300同上。SrConfig程序初始化数据库时写0xff，代表控制器尚未查询过。|
|StatusCode|binary(1) |控制器状态代码| 上海：0x00 => 正常工作, 0x01 => 下行通道异常, 0x02 => 升级模式, 0xFF => 未知错误。LC300未描述。|
|LastTime|datetime | 最后一次从控制器读取的时间| 用于检查控制器时间是否正常|
|SmsCount|smallint unsigned |短信数量|从控制器读回来的|

## ControllerStatusChanges

记录控制器状态变化。

|字段名 |类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|Controller.idController |PK1|
|field| varchar(32) |被修改的字段名| PK2|
|field_value |varchar(255)|变化后的字段值 |
|time|timestamp | 修改时间|PK3|

目前记录如下两个状态的变化，由 `ControllerStatus` 表中名为 `log_controller_changes` 的trigger执行：

1. CommState: `field_value` 存储 `CAST(CommState AS char)`
2. StatusCode: `field_value` 存储 `HEX(StatusCode)`

每月执行的事件 `Delete outdated status history` 会将超过365天前的记录删除。

## ControllerSchedule

查询时控计划时把结果放到这张表里，将原来该控制器的删掉，再重新插入。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idController|int unsigned|Controller.idController ||
|Item|varchar(128)|时间亮度表的一项|上海：MM, DD, MM, DD, HH, mm, ss, Addr, mode, value (逗号后不加空格)|

## ControllerSchedule_edit

用户编辑时控计划时把结果放到这张表里。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idController|int unsigned|Controller.idController ||
|Item|varchar(128)|时间亮度表的一项|上海：MM, DD, MM, DD, HH, mm, ss, Addr, mode, value (逗号后不加空格)|

## ControllerCellNumbers

控制器上的手机号。
往控制器上面上载手机号，或者从控制器上下载手机号，都是一帧就完成了。
删除手机号是把所有的手机号删除，不能只删除其中的一个。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idController|int unsigned|Controller.idController ||
|Cell|varchar(20) |一个手机号| 不支持国家代码|

## ControllerSms

从控制器里面读回来的短信内容放在这张表里面。

|字段名 |类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|Controller.idController| PK1|
|SmsIndex|smallint unsigned|短信在设备中的序号| PK2|
|SmsContent|varchar(450)||UTF8|

## ControllerLog

从控制器里面读回来的日志内容放在这张表里面。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|Controller.idController| PK1|
|LogTime |datetime | 日志记录时间|PK2|
|LogContent|text|日志内容|UTF8|

## Device

| 字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idDevice|int unsigned|||
|Name|varchar(128)|||
|MAC |binary(8)| ||
|DisplayOrder|int unsigned|前台程序界面上显示的顺序||
|Note|varchar(450)|备注，比如位置信息|UTF8|

## DeviceStatus

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idDevice|int unsigned|Device.idDevice ||
|VersionSoftware |binary(4) |软件版本号| LC300：只用2字节|
|VersionHardware |binary(4) |硬件版本号| LC300：只用2字节|
|ManufacturerInfo|varchar(450) |厂商信息文本|上海：厂商描述。LC300：终端设备产品信息，<=32字节，ASCII码。 |
|ManufactureTime |datetime | 出厂时间|LC300：无|
|Type|binary(4) |设备类型|上海4.4.1 LC300 4.6.1 `0x0E`|
|SN|varchar(64) |产品序列号| |
|InputVolt| double  |输入电压采样值 ||
|InputAmp|double  |输入电流采样值 ||
|OutputVolt|double  |输出电压采样值 ||
|OutputAmp| double  |输出电流采样值 ||
|ActivePower |double  |有功功率采样值 ||
|Temperature |smallint |温度采样值| LC300：1字节|
|TemperatureGuard|binary(4) |过温保护状态 过温保护参数| LC300 4.6 `0x0A`|
|Uptime|int unsigned |上电工作时间||
|UptimeTotal |int unsigned |总工作时间| |
|ElectricityConsumption|int unsigned |消耗电量值| |
|TransitionTime|tinyint unsigned |调光渐变时间||
|Brightness|tinyint unsigned |当前亮度||
|BrightnessMin| tinyint unsigned |最小亮度值| |
|BrightnessMax| tinyint unsigned | 最大亮度值| |
|BrightnessMinPhysical| tinyint unsigned |物理最小亮度值 ||
|BrightnessMaxPhysical| tinyint unsigned | 物理最大亮度值|LC300未定义|
|BrightnessPowerOn| tinyint unsigned |上电亮度值| |
|BrightnessDefault| tinyint unsigned |默认故障亮度值 ||
|BrightnessCoefficiency|tinyint unsigned | 调光系数|实际亮度 = 设置亮度 * 调光系数 / 100|
|Status|binary(1) |设备状态|上海：4.5.1 LC300：4.6 `0x06`|
|StatusComm|binary(1) |通讯状态|上海：4.5.1|
|StatusLamp|binary(1) |灯具状态|上海：4.5.1|
|SensorI |binary(4) |光强传感器采样值|上海：光感亮度采样值|
|LC300：终端传感器设备光强值|
|SensorL |binary(4) |光照传感器采样值|LC300：终端传感器设备光照值|
|SensorH |binary(4) |湿度传感器采样值||
|SensorT |binary(4) |车流量传感器采样值| |
|GroupMask| binary(32) |分组掩码|一共256 bit，若灯属于第N个组，则bit(N)=1。上海：组地址是1-254。LC300：组地址是0-63|

## DeviceStatus_edit

StarRiver Config 在此记录用户录入的设备初始信息。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idDevice|int unsigned|Device.idDevice ||
|TransitionTime|tinyint unsigned |调光渐变时间||
|BrightnessMin| tinyint unsigned |最小亮度值| |
|BrightnessMax| tinyint unsigned | 最大亮度值| |
|BrightnessMinPhysical| tinyint unsigned |物理最小亮度值 ||
|BrightnessMaxPhysical| tinyint unsigned | 物理最大亮度值|LC300未定义|
|BrightnessPowerOn| tinyint unsigned |上电亮度值| |
|BrightnessDefault| tinyint unsigned |默认故障亮度值 ||
|BrightnessCoefficiency|tinyint unsigned | 调光系数|实际亮度 = 设置亮度 * 调光系数 / 100|
|GroupMask| binary(32) |分组掩码|一共256 bit，若灯属于第N个组，则bit(N)=1。上海：组地址是1-254。LC300：组地址是0-63。|

## DeviceStatusChanges

记录设备状态变化。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idDevice|int unsigned|Device.idDevice |PK1|
|field| varchar(32) |被修改的字段名 |PK2|
|field_value |varchar(255)|变化后的字段值 ||
|time|timestamp  |修改时间|PK3|

目前记录如下三个状态的变化，由DeviceStatus表中名为log_changes的trigger执行：

1. Status: `field_value` 存储 `HEX(Status)`
2. StatusComm: `field_value` 存储 `HEX(StatusComm)`
3. StatusLamp: `field_value` 存储 `HEX(StatusLamp)`

## DeviceStatusHistory*

以下三张表的字段定义大部分相同，分别记录不同粒度的状态量历史。

1. DeviceStatusHistory
2. DeviceStatusHistory_hourly
3. DeviceStatusHistory_daily

三张表共同部分的定义如下：

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idDevice|int unsigned|Device.idDevice| PK1|
|field| varchar(32) |被修改的字段名 |PK2|
|field_value |double|字段采样值| |
|time|timestamp  |修改时间|PK3|

两张汇总表有额外记录汇总时段内峰值、谷值的字段。

1. DeviceStatusHistory_hourly
2. DeviceStatusHistory_daily

峰谷值定义如下:

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|field_max| double|汇总时段内最大采样值|浮点数可能无法精确表示整数采样|
|field_min| double|汇总时段内最小采样值|浮点数可能无法精确表示整数采样|

有三个event更新这些表：

1. 每5分钟，对 `DeviceStatus` 进行采样，记录设备的状态量。
2. 每天，将前一天的采样归纳成每小时均值。删除3天前的采样。
3. 每周，将前一周的采样归纳成每日均值。删除一周前的小时均值。

每月执行的事件 `Delete outdated status history` 会将 `DeviceStatusHistory_daily` 中超过365天前的记录删除。

## DeviceSchedule

LCP-SH-D：该功能是在单灯控制器与集中控制器失去联系后采用的异常模式，如果在某一时间段内没有设置该亮度值的话，将采用默认故障亮度值显示。

> **注意** 调光计划的总数不能超过7。

LC300没有定义。

|字段名| 类型|含义|备注|
| --- | --- | --- | --- |
|idDeviceSchedule|bigint unsigned| 自增ID||
|idDevice|int unsigned|Device.idDevice ||
|Item|varchar(32) |自动亮度表的一项|HH,mm,value|

## DeviceScene

LCP-SH-D协议场景号是1-254。
LC300协议，场景号是1-16，0表示无场景。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idDeviceScene| tinyint unsigned| ||
|idDevice|int unsigned|Device.idDevice ||
|Brightness|tinyint unsigned |灯的场景亮度值 |0-100|

## DeviceReportCond

信息上报条件。用于保存要给哪些灯设置信息上报条件。

LC300未定义。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idDevice|int unsigned|Device.idDevice ||
|Item|varchar(128)|信息上报的一项|StatusID,low,high|

## DeviceAlarmCond

报警阈值条件。用于保存要给哪些灯设置报警阈值条件。

LC300未定义。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idDevice|int unsigned|Device.idDevice||
|Item|varchar(450)|报警阈值的一项 |StatusID, low, high, warn_msg （逗号后不加空格）|

## DeviceMessages

和上面两张表相关，上面设置了信息上报条件，这样对上报上来的信息应该有一个地方记住。同一个类型的上报报警信息，如果报了两条，则后面的那条应该把前面那条覆盖掉。

LC300未定义。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID||
|idDevice|int unsigned|Device.idDevice ||
|MsgTime |timestamp | ||
|Item|varchar(450)|报警阈值的一项 |StatusID,value,msg (若非报警，msg留空)|

## TaskTodo

待处理的用户操作。

服务器进程每隔一段时间在这里取任务，分别处理。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|id|bigint unsigned| 自增ID|当流水号|
|Time|datetime|||
|idUser|int unsigned |User.idUser ||
|Command |smallint unsigned|操作类型||
|Parameters|varchar(1024) |操作的参数| |
|MD5| varchar(40)| 命令的MD5散列值|md5(Time + idUser + Command + Parameters) 作为查询条件供前段程序在TaskDone中查询任务完成状态|

> **注意**：这个表使用MyISAM引擎存储。自增的id字段如果使用InnoDB存储，计数器在内存里，数据库服务器一旦重启，又将从1开始计数，完成任务后向 `TaskDone` 中插入记录会引发冲突导致失败。

## TaskDone

记录那些已完成的用户操作。

`TaskTodo` 中的任务，处理完毕后，从 `TaskTodo` 删除，将结果插入到表 `TaskDone` ，保持 `TaskTodo` 中字段信息不变。

除了 `TaskTodo` 的字段，另有以下字段：

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|FinishedTime|timestamp  |完成时间|插入记录时由数据库自动生成|
|ReturnCode|smallint |返回代码|成功：0；失败：控制器返回的确认码 bitwise-OR；控制器未能返回结果（如超时）：-2。|
|ErrorMsg|varchar(255) | 错误描述信息|UTF8|

有一个 event (*Remove outdated tasks from TaskDone*) 每周清理创建时间在14天之前的任务，以保证这张表不会无限膨胀下去。

## Firmware

| 字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFirmware|int unsigned| ||
|Firmware|mediumblob|二进制内容||
|FirmwareMD5 |char(32)|md5(Firmware)| |
|FirmwareName|varchar(64) |固件包名称| 终端用|
|FirmwareVersion| binary(4)| 固件版本号| 终端用|
|Note|varchar(300)||UTF8|

MediumBlob可以存储16MB大小的固件，MySQL服务器也已经设置：

`max_allowed_packet=16M`

## FrontendMapBmp

| 字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFrontendMapBmp|tinyint unsigned| ||
|Name|varchar(64)|||
|DisplayOrder|tinyint unsigned |前台程序界面上显示地图的顺序|不宜重复|

## FrontendGroup

对于LCP-SH-D和LC300协议：现在用户的组和灯的组是统一的，即用户的第一个组就是所有灯的第一个组；对于CSA来说，一个用户的组可能对应控制器1的网关ID1和控制器2的网关ID2，所以还要建一张表来指定用户组和控制器里网关ID的关系(有点像以前LC200)。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFrontendGroup| tinyint unsigned| ||
|Name|varchar(64)| ||
|Color| tinyint unsigned| |Config程序里作为选项|

## FrontendScene

这是用户定义的场景。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFrontendScene |tinyint unsigned| ||
|Name|varchar(64)| ||
|DisplayOrder|tinyint unsigned||不宜重复|

## FrontendControllerDevices

描述灯属于哪个控制器。

对于CSA的协议，灯是属于控制器下的某个网关ID，所以可能会增加一个字段表示灯属于控制器的哪个网关。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idController|int unsigned|Controller.idController|PK1|
|idDevice|int unsigned|Device.idDevice|PK2|
|DeviceDisplayOrder|int unsigned|界面显示该控制器下的灯时的序号||
|PortOnController|smallint unsigned | 灯在控制器的哪个口上|可能不需要|

## FrontendGroupDevices

描述灯属于哪个组。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFrontendGroup| tinyint unsigned |FrontendGroup. idFrontendGroup|PK1|
|idDevice|int unsigned|Device.idDevice|PK2|
|DeviceDisplayOrder|int unsigned|界面显示该组内的灯时的序号|不宜重复|

## FrontendDeviceMap

描述各种设备在BMP地图上的信息。

|字段名|类型|含义|备注|
| --- | --- | --- | --- |
|idFrontendMapBmp|int unsigned|FrontendMapBmp. idFrontendMapBmp|PK1|
|DeviceType|tinyint unsigned |表明设备类型，如控制器、灯等| PK2|
|idDevice|int unsigned|Device.idDevice or Controller.idController| PK3|
|PosX|int |设备在地图上的横坐标| |
|PosY|int |设备在地图上的纵坐标| |
|idIcon|tinyint unsigned||对应的图标文件必须存在|
